class Repo < ApplicationRecord
  has_many :commits
  has_many :contributions
  has_many :users, through: :contributions

  has_many :issues
  has_many :pull_requests

  validates :name, presence: true
end
