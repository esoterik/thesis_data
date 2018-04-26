class AddPrCommitDiffToContributions < ActiveRecord::Migration[5.1]
  def change
    add_column :contributions, :diff, :decimal
  end
end
