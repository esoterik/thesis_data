class FirstContributionCalculator
  def initialize(contribs = nil)
    @contribs = contribs || Contribution.includes({ users: %i(commits pull_requests) },
                                                  :repos).all
  end

  def run
    contribs.each do |c|
      first_commit = c.user.commits.where(repo: c.repo).order(:time).first
      first_pr = c.user.pull_requests.where(repo: c.repo).order(:opened).first
      c.update!(first_commit: first_commit.time, first_pr: first_pr.time)
    end
  end

  private
  
  attr_reader :contribs
end
