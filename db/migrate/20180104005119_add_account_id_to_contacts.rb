class AddAccountIdToContacts < ActiveRecord::Migration[5.1]
  def change
    add_column :contacts, :account_id, :integer, null: false
  end
end
