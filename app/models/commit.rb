class Commit < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :repo

  validates :repo, presence: true
  validates :message, presence: true
  validates :time, presence: true
  validates :additions, numericality: { only_integer: true,
                                        greater_than_or_equal_to: 0 }
  validates :deletions, numericality: { only_integer: true,
                                        greater_than_or_equal_to: 0 }
  validates :diff, numericality: { only_integer: true }

  # TODO: null user object
end
