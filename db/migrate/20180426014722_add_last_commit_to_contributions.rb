class AddLastCommitToContributions < ActiveRecord::Migration[5.1]
  def change
    add_column :contributions, :last_commit, :datetime
  end
end
