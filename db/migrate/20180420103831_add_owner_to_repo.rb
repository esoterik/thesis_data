class AddOwnerToRepo < ActiveRecord::Migration[5.1]
  def change
    add_column :repos, :owner, :string
  end
end
