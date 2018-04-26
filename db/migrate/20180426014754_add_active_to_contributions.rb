class AddActiveToContributions < ActiveRecord::Migration[5.1]
  def change
    add_column :contributions, :active, :boolean
  end
end
