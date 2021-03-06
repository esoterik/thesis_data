class Conversation < ApplicationRecord
  belongs_to :issue, optional: true
  belongs_to :pull_request, optional: true

  has_many :comments, dependent: :destroy
  has_many :participants, through: :comments, source: 'author'

  validate :belongs_to_issue_or_pr

  private

  def belongs_to_issue_or_pr
    return unless issue_id.blank? && pull_request_id.blank?
    errors.add(:base, "Must belong to an issue or a PR")
  end
end
