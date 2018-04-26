class Commit < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :repo

  validates :repo, presence: true
  validates :message, presence: true
  validates :time, presence: true
  validates :sha, presence: true, uniqueness: { scope: :repo }
  validates :additions, numericality: { only_integer: true,
                                        greater_than_or_equal_to: 0,
                                        allow_nil: true }
  validates :deletions, numericality: { only_integer: true,
                                        greater_than_or_equal_to: 0,
                                        allow_nil: true }
  validates :diff, numericality: { only_integer: true, allow_nil: true }

  def self.before(date)
    where('time < ?', date)
  end

  # TODO: null user object
end
