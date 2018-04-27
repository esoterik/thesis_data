require 'sentimental'

class SentimentalRunner
  def initialize
    @runner = Sentimental.new
    runner.load_defaults
  end

  def analyze(text)
    runner.score text
  end

  private

  attr_reader :runner
end
