class CreateIssues < ActiveRecord::Migration[5.1]
  def change
    create_table :issues do |t|
      t.string :title
      t.text :body
      t.datetime :opened
      t.datetime :closed
      t.integer :status
      t.integer :number
      t.belongs_to :author
      t.belongs_to :repo

      t.timestamps
    end
  end
end
