class ChatUpdate
  include MongoMapper::Document

  key :user_id, Integer
  key :chat_room_id, Integer
  key :login, String
  key :message, String

  timestamps!

  validates_presence_of :user_id, :chat_room_id, :login
  validates_numericality_of :user_id

  # -1 second needed as time in database is saved without usec part
  scope :newer_than, lambda {|time| {:created_at.gte => time.utc - 1.second}}

  def user
    User.find(user_id)
  end

  def user=(user)
    self.user_id = user.id
    self.login = user.name
  end

  def chat_room=(chat_room)
    self.chat_room_id = chat_room.id
  end

end
