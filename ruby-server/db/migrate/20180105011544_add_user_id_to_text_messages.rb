class AddUserIdToTextMessages < ActiveRecord::Migration[5.1]
  def change
    add_column :text_messages, :user_id, :integer
  end
end
