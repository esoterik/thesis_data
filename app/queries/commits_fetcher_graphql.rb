require 'graphql/client'

class CommitsFetcherGraphQL
  FirstQuery = Github::Client.parse <<-'GRAPHQL'
    query($owner: String!, $name: String!) {
      repository(owner: $owner, name: $owner) {
        ref(qualifiedName: "master") {
          target {
            ... on Commit {
              history(first: 5) {
                pageInfo {
                  hasNextPage
                  endCursor
                }
                edges {
                  node {
                    oid
                    message
                    additions
                    deletions
                    authoredDate
                    author {
                      user {
                        login
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  GRAPHQL

  Query = Github::Client.parse <<-'GRAPHQL'
    query($owner: String!, $name: String!, $after: String!) {
      repository(owner: $owner, name: $owner) {
        ref(qualifiedName: "master") {
          target {
            ... on Commit {
              history(first: 5, after: $after) {
                pageInfo {
                  hasNextPage
                  endCursor
                }
                edges {
                  node {
                    oid
                    message
                    additions
                    deletions
                    authoredDate
                    author {
                      user {
                        login
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  GRAPHQL

  def initialize(repo)
    @repo = repo
    @name_vars = { owner: repo.owner, name: repo.name }
  end

  def save_commits
    first_results = Github::Client.query(FirstQuery, variables: name_vars)
    binding.pry
    #save_commits!(commits)
  end

  private
  
  attr_reader :repo, :name_vars



  def save_commits!(commits)
    commits.each do |c|
      user = User.find_by(username: c[:author][:login]) if c[:author]
      Commit.create!(user: user, repo: repo, sha: c[:sha],
                     time: c[:commit][:author][:date],
                     message: c[:commit][:message])
    end
  end
end
