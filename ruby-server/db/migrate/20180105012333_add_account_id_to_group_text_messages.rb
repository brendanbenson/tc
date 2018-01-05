class AddAccountIdToGroupTextMessages < ActiveRecord::Migration[5.1]
  def change
    add_column :group_text_messages, :account_id, :integer
  end
end
