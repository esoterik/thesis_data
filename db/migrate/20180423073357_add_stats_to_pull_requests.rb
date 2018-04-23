class AddStatsToPullRequests < ActiveRecord::Migration[5.1]
  def change
    add_column :pull_requests, :additions, :integer
    add_column :pull_requests, :deletions, :integer
    add_column :pull_requests, :changed_files, :integer
    add_column :pull_requests, :diff, :integer
  end
end
