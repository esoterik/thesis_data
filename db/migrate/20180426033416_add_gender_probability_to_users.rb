class AddGenderProbabilityToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :gender_prob, :decimal
  end
end
