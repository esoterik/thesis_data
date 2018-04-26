class Contribution < ApplicationRecord
  belongs_to :user
  belongs_to :repo

  # Returns contributions with first commit dates AFTER the given time
  def self.after(date)
    where('first_commit >= ?', date)
  end

  def excluded?
    first_commit < repo.first_pr_date || first_pr.nil?
  end
end
