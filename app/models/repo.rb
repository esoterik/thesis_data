class Repo < ApplicationRecord
  has_many :commits
  has_many :contributions
  has_many :users, through: :contributions

  validates :name, presence: true
end
