class AddMetricsToContributions < ActiveRecord::Migration[5.1]
  def change
    add_column :contributions, :avg_commit_size, :decimal
    add_column :contributions, :last_pr, :datetime
    add_column :contributions, :first_pr_status, :integer
    add_column :contributions, :last_pr_status, :integer
    add_column :contributions, :commits_at_first_pr, :integer
    add_column :contributions, :more_than_a_year, :boolean
    add_column :contributions, :total_commits, :integer
    add_column :contributions, :total_prs, :integer
    add_column :contributions, :total_adds, :integer
    add_column :contributions, :total_dels, :integer
  end
end
