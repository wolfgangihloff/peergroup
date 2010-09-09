class AddLeaderAndProblemOwnerColumnsToChatRooms < ActiveRecord::Migration
  def self.up
    change_table :chat_rooms do |chat_rooms|
      chat_rooms.belongs_to :leader
      chat_rooms.belongs_to :problem_owner
    end
  end

  def self.down
    change_table :chat_rooms do |chat_rooms|
      chat_rooms.remove :leader_id
      chat_rooms.remove :problem_owner_id
    end
  end
end
