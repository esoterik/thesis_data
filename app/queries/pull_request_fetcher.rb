require 'graphql/client'

class PullRequestFetcher
  # next: Y3Vyc29yOnYyOpHOBTOk9Q==
  FirstQuery = Github::Client.parse <<-'GRAPHQL'
    query($owner: String!, $name: String!) {
      repository(owner: $owner, name: $name) {
       pullRequests(first: 50) {
          pageInfo {
            hasNextPage
            endCursor
          }
          nodes {
            number
            title
            bodyText
            additions
            deletions
            changedFiles
            state
            createdAt
            closedAt
            mergedAt
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
                bodyText
                createdAt
                author {
                  login
                }
              }
            }
            reviews(first: 100) {
              nodes {
                createdAt
                author {
                  login
                }
                comments(first: 20) {
                  nodes {
                    bodyText
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
        pullRequests(first: 10, after: $after) {
          pageInfo {
            hasNextPage
            endCursor
          }
          nodes {
            number
            title
            bodyText
            additions
            deletions
            changedFiles
            state
            createdAt
            closedAt
            mergedAt
            assignees(first: 5) {
              nodes {
                login
              }
            }
            comments(first: 100) {
              nodes {
                bodyText
                createdAt
                author {
                  login
                }
              }
            }
            reviews(first: 100) {
              nodes {
                createdAt
                author {
                  login
                }
                comments(first: 20) {
                  nodes {
                    bodyText
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
    @prs = []
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
      @prs = results_hash['nodes']
      create_prs
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
        return next_id
      end
    end
    return 'Complete'
  end

  private

  attr_reader :repo, :name_vars, :prs, :users, :start_point

  def dig_user(node)
    return nil unless node['author']
    node.dig(*%w(author login))
  end

  def comments_from_pr!(pr_hash, pr)
    conversation = pr.conversation
    comments_hashes = pr_hash.dig(*%w(comments nodes))
    comments_hashes.each do |c|
      c = delete_null_bytes(c)
      auth = users[dig_user(c)]
      auth = auth.first if auth
      Comment.create!(conversation: conversation, author: auth,
                      body: c['bodyText'],
                      time: DateTime.iso8601(c['createdAt']),
                      category: 'normal')
    end
  end

  def assignees_from_pr!(pr_hash, pr)
    pr_hash.dig(*%w(assignees nodes)).map do |a| 
      username = a['login'] 
      user = users[username].try(:first)
      next unless user
      Assignment.create!(pull_request: pr, user: user)
    end
  end

  def reviews_from_pr!(pr_hash, pr)
    conversation = pr.conversation
    reviews_hashes = pr_hash.dig(*%w(reviews nodes))
    reviews_hashes.each do |c|
      c = delete_null_bytes(c)
      auth = users[dig_user(c)]
      auth = auth.first if auth
      next if c['comments']['nodes'].empty?
      body = c['comments']['nodes'].first['bodyText']
      Comment.create!(conversation: conversation, author: auth, body: body,
                      time: DateTime.iso8601(c['createdAt']),
                      category: 'review')
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

  def create_prs
    prs.each do |p|
      user = users[dig_user(p)]
      user = user.first if user
      ActiveRecord::Base.transaction do
        p = delete_null_bytes(p)
        closed = DateTime.iso8601(p['closedAt']) if p['closedAt']
        diff = p['additions'] - p['deletions']
        pr = PullRequest.create!(author: user, repo: repo, title: p['title'],
                                 body: p['bodyText'],
                                 changed_files: p['changedFiles'],
                                 status: p['state'].downcase,
                                 number: p['number'], additions: p['additions'],
                                 deletions: p['deletions'], diff: diff,
                                 opened: DateTime.iso8601(p['createdAt']),
                                 closed: closed)
        Conversation.create!(pull_request: pr)
        comments_from_pr!(p, pr)
        assignees_from_pr!(p, pr)
        reviews_from_pr!(p, pr)
      end
    rescue ActiveRecord::RecordInvalid
      puts "FAILED TO CREATE PULL REQUEST: #{i['number']}"
      next
    end
  end
end
