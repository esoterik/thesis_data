class ContributionCalculator
  def initialize(contribs = nil)
    @contribs = contribs || Contribution.includes({ user: %i(commits pull_requests) },
                                                  { repo: :commits }).all
  end

  def run
    contribs.each do |c|
      commits = c.user.commits.where(repo: c.repo).order(:time)
      prs = c.user.pull_requests.where(repo: c.repo).order(:opened)
      attrs = dates(commits, prs)
      attrs[:total_adds] = commits.sum(:additions)
      attrs[:total_dels] = commits.sum(:deletions)
      attrs[:total_commits] = commits.count
      attrs[:avg_commit_size] = (attrs[:total_adds] + attrs[:total_dels]) / 
        attrs[:total_commits].to_f
      attrs[:total_prs] = prs.count
      attrs[:first_pr_status] = prs.first.status unless prs.empty?
      attrs[:last_pr_status] = prs.last.status unless prs.count < 2
      c.update!(dates)
    end
  end

  private
  
  attr_reader :contribs

  def dates(commits, prs)
    length = commits.last.time - commits.first.time
    frequency = commits.count / length if length != 0
    dates = { first_commit: commits.first.time,
              last_commit: commits.last.time,
              length: length, frequency: frequency,
              active: commits.last.time < 1.month.ago }
    unless prs.empty?
      dates[:first_pr] = prs.first.opened 
      dates[:commits_at_first_pr] = repo.commits.before(prs.first.opened).count
      diff = prs.first.opened - commits.first.time
      diff = -diff if commits.first.time < prs.first.opened
      diff = 0 if diff.negative? && diff.abs < 1.day
      dates[:diff] = diff
      dates[:more_than_a_year] = diff > 1.year
    end
  end
end
