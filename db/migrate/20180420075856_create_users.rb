class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :username, null: false
      t.string :email
      t.integer :gender_name

      t.timestamps
    end
  end
end
