class AddExcludedToConversations < ActiveRecord::Migration[5.1]
  def change
    add_column :conversations, :excluded, :boolean
  end
end
