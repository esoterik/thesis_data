class AddLengthToComments < ActiveRecord::Migration[5.1]
  def change
    add_column :comments, :length, :integer
  end
end
