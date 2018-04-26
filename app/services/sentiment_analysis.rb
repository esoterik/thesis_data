class SentimentAnalysis
  def initialize(comments)
    @comments = comments
    @api = WatsonSentiment.new
  end

  def run
    comments.find_each do |c|
      # skip if we've already calculated the sentiment
      next unless c.sentiment.nil?
      # skip if outside the limits of watson's API
      next unless c.body.length > 15 && c.body.length < 10000
      c.update!(api.analyze c.body)
    end
  end

  private
  
  attr_reader :comments, :api
end
