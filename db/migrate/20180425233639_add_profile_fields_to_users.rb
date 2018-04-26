class AddProfileFieldsToUsers < ActiveRecord::Migration[5.1]
  def change
    change_table :users do |t|
      t.string :location
      t.string :bio
      t.string :company
      t.string :first_name
    end
  end
end
