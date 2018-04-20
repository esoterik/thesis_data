class CreateRepos < ActiveRecord::Migration[5.1]
  def change
    create_table :repos do |t|
      t.string :name, null: false
      t.string :languages

      t.timestamps
    end
  end
end
