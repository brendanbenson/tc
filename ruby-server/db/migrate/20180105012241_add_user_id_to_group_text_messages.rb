class AddUserIdToGroupTextMessages < ActiveRecord::Migration[5.1]
  def change
    add_column :group_text_messages, :user_id, :integer
  end
end
