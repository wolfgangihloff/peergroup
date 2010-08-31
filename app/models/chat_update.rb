class ChatUpdate
  include MongoMapper::Document

  key :user_id, Integer
  key :login, String
  key :text, String

  timestamps!

  validates_presence_of :user_id, :login
  validates_numericality_of :user_id

  def user
    User.find(user_id)
  end
end
