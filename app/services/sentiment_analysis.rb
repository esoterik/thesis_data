require 'uri'

class SentimentAnalysis
  def initialize(comments, api = SentimentalRunner.new)
    @comments = comments
    @api = api
  end

  def run
    comments.find_each do |c|
      next if c.length > 10000 # for sanity, cuts out less than 1000 comments
      url_removed = strip_urls(c.body)
      c.update!(sentiment: api.analyze(url_removed))
    rescue
      puts "failed to calculate sentiment for #{c.id}"
    end
  end

  private

  attr_reader :comments, :api

  def strip_urls(text)
    text.sub(URI.regexp, '')
  end
end
