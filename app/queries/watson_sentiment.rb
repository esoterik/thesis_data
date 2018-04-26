require 'faraday'

class WatsonSentiment
  API_URL = 'https://gateway.watsonplatform.net/'
  WATSON_CREDENTIALS_FILE = 'watson_credentials'

  def initialize
    read_username_and_password
    @conn = Faraday.new(url: API_URL) do |faraday|
      faraday.basic_auth(username, password)
      faraday.headers['Content-Type'] = 'application/json'
      faraday.response :logger
      faraday.adapter Faraday.default_adapter
    end
  end

  def analyze(text)
    result = conn.get 'natural-language-understanding/api/v1/analyze',
      { version: '2018-03-16', text: text, features: 'sentiment,emotion' }
    hash = JSON.parse result.env.body
    sentiment_score = hash.dig(*%w(sentiment document score))
    { 'sentiment' => sentiment_score }.merge(hash.dig(*%w(emotion document emotion)))
  end

  private

  attr_reader :conn, :username, :password

  def read_username_and_password
    creds = File.readlines(WATSON_CREDENTIALS_FILE)
    @username = creds.first.chomp
    @password = creds.last.chomp
  end
end
