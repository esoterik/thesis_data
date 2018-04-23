class AddAttributesToContributions < ActiveRecord::Migration[5.1]
  def change
    add_column :contributions, :first_pr, :datetime
    add_column :contributions, :first_commit, :datetime
  end
end
