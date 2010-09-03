class ChatRoom < ActiveRecord::Base
  belongs_to :group

  def chat_updates
    ChatUpdate.where(:chat_room_id => id)
  end
end
