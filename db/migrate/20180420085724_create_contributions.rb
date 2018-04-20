class CreateContributions < ActiveRecord::Migration[5.1]
  def change
    create_table :contributions do |t|
      t.integer :count, null: false
      t.belongs_to :user, null: false
      t.belongs_to :repo, null: false

      t.timestamps
    end
  end
end
