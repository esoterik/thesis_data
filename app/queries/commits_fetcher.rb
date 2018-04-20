require 'octokit'

class CommitsFetcher
  def initialize(repo)
    @repo = repo
    @client = Octokit::Client.new(access_token: File.read(ACCESS_TOKEN_FILE).chomp,
                                  per_page: 100)
    @name_vars = { 'owner' => repo.owner, 'name' => repo.name }
  end

  def save_commits
    first_five = get_commits(first_five_commits)
    # first_five.each do |c|
    #   user = User.find_by(username: c.dig(*%w(author user login)))
    #   diff = c['additions'] - c['deletions']
    #   Commit.create!(user: user, repo: repo, message: c['message'],
    #                  diff: diff, additions: c['additions'],
    #                  deletions: c['deletions'],
    #                  time: Date.iso8601(c['committedDate']))
    # end
    binding.pry    
    #comment
  end

  private
  
  attr_reader :name_vars, :repo

  def later_commits(date)
    Github::Client.query(Query, variables: name_vars.merge('before' => date))
  end

  def first_five_commits
    @first_five_query ||= Github::Client.query(FirstQuery,
                                               variables: name_vars)
    @first_five_query.original_hash
  end

  def get_commits(hash)
    hash.dig('data', 'repository', 'ref', 'target', 'history',
             'edges').map { |h| h['node'] }
  end

end
