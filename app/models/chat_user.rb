class ChatUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :chat_room

  named_scope :present, lambda {
    {:conditions => ["chat_users.updated_at > ?", 10.seconds.ago]}
  }

  named_scope :by_username, :order => "users.name", :include => :user

  def active?
    uptodate = ChatUpdate.newer_than(3.seconds.ago)
    uptodate.first(:user_id => user.id, :chat_room_id => chat_room.id)
  end
end

