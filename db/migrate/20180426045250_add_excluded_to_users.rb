class AddExcludedToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :excluded, :boolean
  end
end
