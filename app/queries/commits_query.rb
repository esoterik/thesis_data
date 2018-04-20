require 'graphql/client'
require 'graphql/client/http'

class CommitsQuery
  def initialize(repo)
    @repo = repo
    setup_graphql
  end

  def save_commits
  end

  private
  
  attr_reader :repo

  def setup_graphql

  end
end
