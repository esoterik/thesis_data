class AddBlogToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :blog, :string
  end
end
