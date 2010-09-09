class ChatRoom < ActiveRecord::Base
  belongs_to :group
  belongs_to :leader, :class_name => 'User'
  belongs_to :problem_owner, :class_name => 'User'

  def chat_updates
    ChatUpdate.where(:chat_room_id => id)
  end
end
