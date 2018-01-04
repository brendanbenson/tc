class AddAccountIdToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :account_id, :integer
    drop_table :user_accounts
  end
end
