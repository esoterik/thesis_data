class User < ApplicationRecord
  has_many :commits
  has_many :contributions
  has_many :repos, through: :contributions
  has_many :pull_requests, foreign_key: 'author_id'
  has_many :issues, foreign_key: 'author_id'
  has_many :comments, foreign_key: 'author_id'
  has_many :conversations, through: :comments

  validates :username, presence: true, uniqueness: true

  enum gender_name: %i(unknown female male)

  def last_name
    return nil unless name
    last_name = name.split(' ').last
    return nil if last_name == first_name
    last_name
  end
end
