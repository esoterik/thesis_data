require 'graphql/client'

class IssuesFetcher
  FirstQuery = Github::Client.parse <<-'GRAPHQL'
    query($owner: String!, $name: String!) {
      repository(owner: $owner, name: $name) {
        issues(first: 100) {
          pageInfo {
            hasNextPage
            endCursor
          }
          edges {
            node {
              number
              title
              body
              state
              createdAt
              closedAt
              author {
                login
              }
              assignees(first: 5) {
                nodes {
                  login
                }
              }
              comments(first: 100) {
                nodes {
                  id
                  author {
                    login
                  }
                  body
                  createdAt
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
        issues(first: 100, after: $after) {
          pageInfo {
            hasNextPage
            endCursor
          }
          edges {
            node {
              number
              title
              body
              state
              createdAt
              closedAt
              author {
                login
              }
              assignees(first: 5) {
                nodes {
                  login
                }
              }
              comments(first: 100) {
                nodes {
                  id
                  author {
                    login
                  }
                  body
                  createdAt
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

  def save_issues
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
      results_hash = results.original_hash.dig(*%w(data repository issues))
      next_id = results_hash.dig(*%w(pageInfo endCursor))
      next_page = results_hash.dig(*%w(pageInfo hasNextPage))
      @issues = issues_from_edges(results_hash['edges'])
      create_issues
      processed_cursors << next_id
      processed += 100
      puts "Processed #{processed}" if (processed % 1000) == 0
      results = Github::Client.query(Query,
                                     variables: name_vars.merge(after: next_id))
      tries = 0
      rescue NoMethodError => e
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

  attr_reader :repo, :name_vars, :issues, :users, :start_point

  def issues_from_edges(edges)
    edges.map { |e| e['node'] }
  end

  def dig_user(node)
    return nil unless node['author']
    node.dig(*%w(author login))
  end

  def comments_from_issue!(issue_hash, issue)
    conversation = Conversation.create!(issue: issue, category: 'comment')
    comments_hashes = issue_hash.dig(*%w(comments nodes))
    comments_hashes.each do |c|
      c = delete_null_bytes(c)
      auth = users[dig_user(c)]
      auth = auth.first if auth
      Comment.create!(conversation: conversation, author: auth, body: c['body'],
                      time: DateTime.iso8601(c['createdAt']))
    end
  end

  def assignees_from_issue!(issue_hash, issue)
    issue_hash.dig(*%w(assignees nodes)).map do |a| 
      username = a['login'] 
      user = users[username].try(:first)
      next unless user
      Assignment.create!(issue: issue, user: user)
    end
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

  def create_issues
    issues.each do |i|
      user = users[dig_user(i)]
      user = user.first if user
      ActiveRecord::Base.transaction do
        i = delete_null_bytes(i)
        closed = DateTime.iso8601(i['closedAt']) if i['closedAt']
        issue = Issue.create!(author: user, repo: repo, title: i['title'],
                             body: i['body'], status: i['state'].downcase,
                             number: i['number'],
                             opened: DateTime.iso8601(i['createdAt']),
                             closed: closed)
        comments_from_issue!(i, issue)
        assignees_from_issue!(i, issue)
      end
    rescue ActiveRecord::RecordInvalid
      puts "FAILED TO CREATE ISSUE: #{i['number']}"
      next
    end
  end
end
