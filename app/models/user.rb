class User < ApplicationRecord
  has_many :commits
  has_many :contributions
  has_many :repos, through: :contributions
  has_many :pull_requests, foreign_key: 'author_id'

  validates :username, presence: true, uniqueness: true
end
