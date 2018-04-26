require 'graphql/client'

class PullRequestAuthorCleaner
  FirstQuery = Github::Client.parse <<-'GRAPHQL'
    query($owner: String!, $name: String!) {
      repository(owner: $owner, name: $name) {
        pullRequests(first: 100) {
          pageInfo {
            hasNextPage
            endCursor
          }
          nodes {
            number
            author {
              login
            }
          }
        }
      }
    }
  GRAPHQL

  Query = Github::Client.parse <<-'GRAPHQL'
    query($owner: String!, $name: String!, $after: String!) {
      repository(owner: $owner, name: $name) {
        pullRequests(first: 100, after: $after) {
          pageInfo {
            hasNextPage
            endCursor
          }
          nodes {
            number
            author {
              login
            }
          }
        }
      }
    }
  GRAPHQL

  def initialize(repo, start_point: nil)
    @repo = repo
    @users = repo.users.group_by(&:username)
    @pull_requests = repo.pull_requests.group_by(&:number)
    @name_vars = { owner: repo.owner, name: repo.name }
    @start_point = start_point
  end

  def run
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
      results_hash = results.original_hash.dig(*%w(data repository pullRequests))
      next_id = results_hash.dig(*%w(pageInfo endCursor))
      next_page = results_hash.dig(*%w(pageInfo hasNextPage))
      update_prs(results_hash)
      processed_cursors << next_id
      processed += 100
      puts "Processed #{processed}" if (processed % 1000) == 0
      results = Github::Client.query(Query,
                                     variables: name_vars.merge(after: next_id))
      tries = 0
      rescue NoMethodError => e
        binding.pry
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
        return next_id
      end
    end
    return 'Complete'
  end

  private

  attr_reader :repo, :name_vars, :pull_requests, :users, :start_point

  def dig_user(node)
    return nil unless node['author']
    node.dig(*%w(author login))
  end

  def delete_null_bytes(hash)
    hash.to_a.map do |k, v| 
      v = if v.is_a? String
            v.delete("\u0000")
          else
            v
          end
      [k, v]
    end.to_h
  end

  def update_prs(hash)
    hash['nodes'].each do |p|
      p = delete_null_bytes(p)
      user = users[dig_user(p)]
      user = user.first if user
      next unless pull_requests.keys.include? p['number']
      pr = pull_requests[p['number']].first
      pr.update!(author: user)
    rescue ActiveRecord::RecordInvalid
      puts "FAILED TO UPDATE PULL REQUEST: #{p['number']}"
      next
    rescue NoMethodError
      puts "FAILED TO UPDATE PULL REQUEST: #{p['number']}"
      next
    end
  end
end
