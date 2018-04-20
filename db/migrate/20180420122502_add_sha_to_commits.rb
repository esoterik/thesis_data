class AddShaToCommits < ActiveRecord::Migration[5.1]
  def change
    add_column :commits, :sha, :string
  end
end
