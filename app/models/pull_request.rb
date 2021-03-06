class PullRequest < ApplicationRecord
  belongs_to :repo
  belongs_to :author, class_name: 'User', optional: true
  has_many :assignments, dependent: :destroy
  has_many :assignees, through: :assignments, class_name: 'User'
  has_one :conversation, dependent: :destroy
  delegate :comments, to: :conversation
  enum status: %i(open closed merged)

  validates :number, uniqueness: { scope: :repo }
end
