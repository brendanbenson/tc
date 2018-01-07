class CreateUserAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :user_accounts do |t|
      t.references :user
      t.references :account
      t.timestamps
    end
  end
end
