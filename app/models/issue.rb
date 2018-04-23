class Issue < ApplicationRecord
  belongs_to :repo
  belongs_to :author, class_name: 'User', optional: true
  has_many :assignments
  has_many :assignees, through: :assignments, class_name: 'User'
  has_one :conversation
  delegate :comments, to: :conversation
  enum status: %i(open closed)

  validates :number, uniqueness: { scope: :repo }
end
