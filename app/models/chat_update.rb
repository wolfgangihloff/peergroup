class ChatUpdate
  include MongoMapper::Document

  key :user_id, Integer
  key :login, String
  key :message, String

  timestamps!

  validates_presence_of :user_id, :login
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
end
