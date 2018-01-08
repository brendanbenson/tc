class CreatePlans < ActiveRecord::Migration[5.1]
  def change
    create_table :plans do |t|
      t.string :slug, unique: true
      t.integer :conversation_messages
      t.timestamps
    end
  end
end
