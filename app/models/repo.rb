class Repo < ApplicationRecord
  has_many :commits
  has_many :contributions
  has_many :users, through: :contributions

  has_many :issues
  has_many :pull_requests

  validates :name, presence: true

  def first_pr_date
    @first_pr_date ||= pull_requests.order(:opened).first.opened
  end
end
