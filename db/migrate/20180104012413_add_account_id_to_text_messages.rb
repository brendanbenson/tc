class AddAccountIdToTextMessages < ActiveRecord::Migration[5.1]
  def change
    add_column :text_messages, :account_id, :integer
  end
end
