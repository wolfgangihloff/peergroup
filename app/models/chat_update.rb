class ChatUpdate
  include MongoMapper::Document

  key :user_id, Integer
  key :chat_room_id, Integer
  key :login, String
  key :message, String
  key :state, String

  timestamps!

  state_machine :state, :initial => :new do
    state :new
    state :uncommited
    state :commited
  end

  validates_presence_of :chat_room_id, :login
  validates_numericality_of :user_id, :allow_nil => true

  # -1 second needed as time in database is saved without usec part
  scope :newer_than, lambda {|time| {:updated_at.gte => time.utc - 1.second}}

  def update_message!(new_message)
    unless new_message == self.message
      self.message = new_message
      self.state = "uncommited"
      save!
    end
  end

  def user
    User.find_by_id(user_id) || nil
  end

  def user=(user)
    self.user_id = user.id
    self.login = user.name
  end

  def chat_room=(chat_room)
    self.chat_room_id = chat_room.id
  end

end
