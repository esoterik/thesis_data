class AddLengthToContributions < ActiveRecord::Migration[5.1]
  def change
    add_column :contributions, :length, :decimal
  end
end
