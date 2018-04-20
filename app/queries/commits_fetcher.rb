require 'octokit'

class CommitsFetcher
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
    # last_response = client.last_response
    # until last_response.rels[:next].nil? || client.rate_limit == 0
    #   commits = last_response.rels[:next].get.data
    #   save_commits!(commits)
    #   puts Commit.last.time
    #   last_response = client.last_response
    # end
    #comment
  rescue ActiveRecord::RecordInvalid
    binding.pry
    puts 'caught error'
    #comment
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
