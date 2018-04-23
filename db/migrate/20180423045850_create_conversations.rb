class CreateConversations < ActiveRecord::Migration[5.1]
  def change
    create_table :conversations do |t|
      t.belongs_to :issue
      t.belongs_to :pull_request
      t.integer :type

      t.timestamps
    end
  end
end
