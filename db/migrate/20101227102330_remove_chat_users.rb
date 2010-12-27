class RemoveChatUsers < ActiveRecord::Migration
  def self.up
    drop_table :chat_users
  end

  def self.down
    create_table :chat_users do |t|
      t.belongs_to :user
      t.belongs_to :chat_room

      t.timestamps
    end
  end
end
