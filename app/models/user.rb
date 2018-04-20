class User < ApplicationRecord
  has_many :commits
  has_many :contributions
  has_many :repos, through: :contributions

  validates :username, presence: true
end
