class Commit < ApplicationRecord
  belongs_to :user
  belongs_to :repo

  validates :repo, presence: true
  validates :message, presence: true
  validates :time, presence: true
  validates :additions, presence: true,
                        numericality: { only_integer: true,
                                        greater_than_or_equal_to: 0 }
  validates :deletions, presence: true,
                        numericality: { only_integer: true,
                                        greater_than_or_equal_to: 0 }
  validates :diff, presence: true, numericality: { only_integer: true }

end
