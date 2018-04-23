class CreatePullRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :pull_requests do |t|
      t.integer :status
      t.datetime :opened
      t.datetime :closed
      t.string :title
      t.text :body
      t.integer :number
      t.belongs_to :author
      t.belongs_to :repo

      t.timestamps
    end
  end
end
