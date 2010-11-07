class ChatUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :chat_room

  scope :present, lambda {
    {:conditions => ["chat_users.updated_at > ?", 10.seconds.ago]}
  }

  scope :by_username, :order => "users.name", :include => :user

  def active?
    uptodate_chat_updates = ChatUpdate.with_message_updated_after(3.seconds.ago)
    uptodate_chat_updates.first(:user_id => user.id, :chat_room_id => chat_room.id)
  end
end

