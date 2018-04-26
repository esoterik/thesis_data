require 'octokit'

class UserQuery
  ACCESS_TOKEN_FILE = 'github_access_token'
  def initialize(user)
    @client = Octokit::Client.new(access_token: File.read(ACCESS_TOKEN_FILE).chomp,
                                  per_page: 100)
    @query = user.username
  end

  def run
    data = client.user(query).to_h
    data.slice(*%i(name company blog location email bio))
  end

  private

  attr_reader :client, :query
end
