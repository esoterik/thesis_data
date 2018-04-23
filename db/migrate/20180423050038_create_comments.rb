class CreateComments < ActiveRecord::Migration[5.1]
  def change
    create_table :comments do |t|
      t.belongs_to :conversation
      t.belongs_to :author
      t.text :body

      t.timestamps
    end
  end
end
