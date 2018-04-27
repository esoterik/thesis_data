class AddSentimentToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :sentiment_toward_notable, :decimal
    add_column :users, :sentiment_toward_other, :decimal
    add_column :users, :sentiment_by, :decimal
  end
end
