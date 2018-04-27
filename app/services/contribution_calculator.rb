class ContributionCalculator
  def initialize(contribs = nil)
    @contribs = contribs || Contribution.includes({ user: %i(commits pull_requests) },
                                                  { repo: :commits }).all
  end

  def run
    contribs.find_each do |c|
      commits = c.user.commits.where(repo: c.repo).order(:time)
      prs = c.user.pull_requests.where(repo: c.repo).order(:opened)
      issues = c.user.issues.where(repo: c.repo).order(:opened)
      next if prs.empty?
      attrs = dates(c, commits, prs)
      attrs[:total_adds] = commits.sum(:additions)
      attrs[:total_dels] = commits.sum(:deletions)
      attrs[:total_commits] = commits.count
      attrs[:avg_commit_size] = (attrs[:total_adds] + attrs[:total_dels]) / 
        attrs[:total_commits].to_f
      attrs[:total_prs] = prs.count
      attrs[:first_pr_status] = prs.first.status
      attrs[:last_pr_status] = prs.last.status unless prs.count < 2
      attrs[:first_issue_opened] = issues.first.opened unless issues.empty?
      c.update!(attrs)
    end
  end

  private
  
  attr_reader :contribs

  def dates(contrib, commits, prs)
    length = commits.last.time - commits.first.time
    frequency = commits.count / length if length != 0
    { 
      first_commit: commits.first.time, last_commit: commits.last.time,
      length: length, frequency: frequency,
      active: commits.last.time > 1.month.ago,
      first_pr: prs.first.opened, last_pr: prs.last.opened,
      commits_at_first_pr: contrib.repo.commits.before(prs.first.opened).count
    }.tap do |dates|
      diff = dates[:first_commit] - dates[:first_pr]
      diff = 0 if diff.negative? && diff.abs < 1.day
      dates[:diff] = diff
      dates[:more_than_a_year] = (dates[:last_commit] - dates[:first_commit]) > 1.year
    end
  end
end
