class CreateAssignments < ActiveRecord::Migration[5.1]
  def change
    create_table :assignments do |t|
      t.belongs_to :issue
      t.belongs_to :pull_request
      t.belongs_to :user

      t.timestamps
    end
  end
end
