class AddCategoryToComments < ActiveRecord::Migration[5.1]
  def change
    add_column :comments, :category, :integer
    change_table :conversations do |t|
      t.remove :category
    end
  end
end
