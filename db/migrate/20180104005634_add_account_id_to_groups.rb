class AddAccountIdToGroups < ActiveRecord::Migration[5.1]
  def change
    add_column :groups, :account_id, :integer, null: false
  end
end
