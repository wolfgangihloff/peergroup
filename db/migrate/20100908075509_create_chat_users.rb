class CreateChatUsers < ActiveRecord::Migration
  def self.up
    create_table :chat_users do |t|
      t.belongs_to :user
      t.belongs_to :chat_room

      t.timestamps
    end

    remove_column :users, :seen_on_chat
  end

  def self.down
    add_column :users, :seen_on_chat, :datetime

    drop_table :chat_users
  end
end

