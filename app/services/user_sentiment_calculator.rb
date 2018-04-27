
class UserSentimentCalculator
  def initialize(users = nil)
    @users = users || User.includes(:conversations).where(excluded: false)
  end

  def run
    users.each do |user|
      user.update!(sentiment_by: user.comments.average(:sentiment))
      user.update!(sentiment_toward_notable: sentiment_toward_notable(user))
      user.update!(sentiment_toward_other: sentiment_toward_other(user))
    end
  end

  private

  attr_reader :users

  def sentiment_toward_notable(user)
    s = []
    user.conversations.includes(:comments).find_each do |c|
      s << c.comments.where.not(author_id: [user.id, nil]).average(:sentiment)
    end
    s.sum / s.size.to_f
  end

  def sentiment_toward_other(user)
    s = []
    user.conversations.includes(:comments).find_each do |c|
      s << c.comments.where(author_id: nil).average(:sentiment)
    end
    s.sum / s.size.to_f
  end
end
