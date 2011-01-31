class AddSupervisionToChatRoom < ActiveRecord::Migration
  def self.up
    add_column :chat_rooms, :supervision_id, :integer

    Supervision.reset_column_information
    Supervision.all.each do |supervision|
      supervision.create_chat_room
    end
  end

  def self.down
    Supervision.all.each do |supervision|
      supervision.chat_room.destroy if supervision.chat_room
    end

    remove_column :chat_rooms, :supervision_id
  end
end
