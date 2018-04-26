class SentimentAnalysis
  def initialize(comments)
    @comments = comments
    @api = WatsonSentiment.new
  end

  def run
    comments.each do |c|
      c.update!(api.analyze c.body)
    end
  end

  private
  
  attr_reader :comments, :api
end
