require 'octokit'

class CommitsFetcherREST
  ACCESS_TOKEN_FILE = 'github_access_token'
  def initialize(repo)
    @repo = repo
    Octokit.auto_paginate = true
    @client = Octokit::Client.new(access_token: File.read(ACCESS_TOKEN_FILE).chomp,
                                  per_page: 100)
  end

  def save_commits
    commits = client.commits "#{repo.owner}/#{repo.name}"
    save_commits!(commits)
  end

  private
  
  attr_reader :client, :repo

  def save_commits!(commits)
    commits.each do |c|
      user = User.find_by(username: c[:author][:login]) if c[:author]
      Commit.create!(user: user, repo: repo, sha: c[:sha],
                     time: c[:commit][:author][:date],
                     message: c[:commit][:message])
    end
  end
end
