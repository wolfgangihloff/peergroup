class AddSeenOnChatColumnToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :seen_on_chat, :time
  end

  def self.down
    remove_column :users, :seen_on_chat
  end
end
