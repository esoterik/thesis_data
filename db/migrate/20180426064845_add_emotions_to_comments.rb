class AddEmotionsToComments < ActiveRecord::Migration[5.1]
  def change
    add_column :comments, :sadness, :decimal
    add_column :comments, :joy, :decimal
    add_column :comments, :fear, :decimal
    add_column :comments, :disgust, :decimal
    add_column :comments, :anger, :decimal
  end
end
