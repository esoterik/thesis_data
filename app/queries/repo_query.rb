require 'octokit'

class RepoQuery
  ACCESS_TOKEN_FILE = 'github_access_token'
  def initialize(repo_string)
    @client = Octokit::Client.new(access_token: File.read(ACCESS_TOKEN_FILE).chomp,
                                  per_page: 100)
    @query = repo_string
  end

  def save_new_repo
    repo = Repo.create!(name: repo_data[:name], languages: repo_data[:language])
    contributor_data.each do |c|
      break if c[:contributions] < 10
      user = User.find_by(username: c[:login])
      user ||= User.create!(username: c[:login])
      Contribution.create!(user: user, repo: repo, count: c[:contributions])
    end
  end

  private

  attr_reader :client, :query

  def repo_data
    @repo_data ||= client.repository(query)
  end

  def contributor_data
    @contributor_data ||= client.contributors(query)
  end
end
