class ChangeTypeColumnNames < ActiveRecord::Migration[5.1]
  def change
    change_table :conversations do |t|
      t.rename :type, :category
    end
  end
end
