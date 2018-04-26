class AddSentimentToComments < ActiveRecord::Migration[5.1]
  def change
    add_column :comments, :sentiment, :decimal
  end
end
