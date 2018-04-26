class ContributionCalculator
  def initialize(contribs = nil)
    @contribs = contribs || Contribution.includes({ user: %i(commits pull_requests) },
                                                  :repo).all
  end

  def run
    contribs.each do |c|
      commits = c.user.commits.where(repo: c.repo).order(:time)
      prs = c.user.pull_requests.where(repo: c.repo).order(:opened)
      length = commits.last.time - commits.first.time
      frequency = commits.count / length if length != 0
      dates = { first_commit: commits.first.time,
                last_commit: commits.last.time,
                length: length, frequency: frequency }
      unless prs.empty?
        dates[:first_pr] = prs.first.opened 
        diff = prs.first.opened - commits.first.time
        diff = -diff if commits.first.time < prs.first.opened
        diff = 0 if diff.negative? && diff.abs < 1.day
        dates[:diff] = diff
      end
      c.update!(dates)
    end
  end

  private
  
  attr_reader :contribs
end
