class AddSupervisionToChatRoom < ActiveRecord::Migration
  def self.up
    add_column :chat_rooms, :supervision_id, :integer

    say_with_time("Creating chat rooms for existing supervisions") do
      Supervision.reset_column_information
      Supervision.all.each do |supervision|
        supervision.create_chat_room
      end
    end
  end

  def self.down
    say_with_time("Destroying chat rooms for supervisions") do
      Supervision.all.each do |supervision|
        supervision.chat_room.destroy if supervision.chat_room
      end
    end

    remove_column :chat_rooms, :supervision_id
  end
end
