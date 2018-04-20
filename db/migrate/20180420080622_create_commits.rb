class CreateCommits < ActiveRecord::Migration[5.1]
  def change
    create_table :commits do |t|
      t.datetime :time, null: false
      t.integer :diff, null: false
      t.integer :additions, null: false
      t.integer :deletions, null: false
      t.text :message
      t.belongs_to :user, index: true
      t.belongs_to :repo, index: true, null: false

      t.timestamps
    end
  end
end
