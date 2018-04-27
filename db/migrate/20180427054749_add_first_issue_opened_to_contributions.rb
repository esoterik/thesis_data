class AddFirstIssueOpenedToContributions < ActiveRecord::Migration[5.1]
  def change
    add_column :contributions, :first_issue_opened, :datetime
  end
end
