require 'graphql/client'

class CommitsFetcherGraphql
  FirstQuery = Github::Client.parse <<-'GRAPHQL'
    query($owner: String!, $name: String!) {
      repository(owner: $owner, name: $name) {
        ref(qualifiedName: "master") {
          target {
            ... on Commit {
              history(first: 100) {
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
      repository(owner: $owner, name: $name) {
        ref(qualifiedName: "master") {
          target {
            ... on Commit {
              history(first: 100, after: $after) {
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

  def initialize(repo, start_point: nil)
    @repo = repo
    @users = repo.users.group_by(&:username)
    @name_vars = { owner: repo.owner, name: repo.name }
    @start_point = start_point
    @commits = []
  end

  def save_commits
    results = if start_point
                Github::Client.query(Query,
                                     variables: name_vars.merge(after: start_point))
              else
                Github::Client.query(FirstQuery, variables: name_vars)
              end
    processed = 0
    next_page = true
    processed_cursors = []
    tries = 0
    while next_page
      begin
      results_hash = results.original_hash.dig(*%w(data repository ref
                                          target history))
      next_id = results_hash.dig(*%w(pageInfo endCursor))
      next_page = results_hash.dig(*%w(pageInfo hasNextPage))
      @commits = commits_from_edges(results_hash['edges'])
      create_commits
      processed_cursors << next_id
      processed += 100
      puts "Processed #{processed}" if (processed % 1000) == 0
      results = Github::Client.query(Query,
                                     variables: name_vars.merge(after: next_id))
      tries = 0
      rescue NoMethodError
        puts "Last processed cursor: #{processed_cursors.last}"
        puts "Current next_id value: #{next_id}"
        if processed_cursors.last == next_id && tries < 5
          tries +=1
          msg = results.original_hash['errors'].first['message']
          puts "ERROR: #{msg}; retrying in 5 sec"
          sleep(5.seconds)
          results = Github::Client.query(Query,
                                         variables: name_vars.merge(after: next_id))
          next
        end
        binding.pry
        next_page = false
      end
    end
  end

  private

  attr_reader :repo, :name_vars, :commits, :users, :start_point

  def commits_from_edges(edges)
    edges.map { |e| e['node'] }
  end

  def dig_user(commit_node)
    return nil unless commit_node['author']
    commit_node.dig(*%w(author user login))
  end

  def create_commits
    commits.each do |c|
      user = users[dig_user(c)]
      user = user.first if user
      diff = c['additions'] - c['deletions']
      Commit.create(user: user, repo: repo, sha: c['oid'],
                     time: DateTime.iso8601(c['authoredDate']),
                     message: c['message'], additions: c['additions'],
                     deletions: c['deletions'], diff: diff)
    end
  end
end
