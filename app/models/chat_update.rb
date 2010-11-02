class ChatUpdate
  include MongoMapper::Document

  key :user_id, Integer
  key :chat_room_id, Integer
  key :login, String
  key :message, String
  key :message_updated_at, Time
  key :state, String
  key :writeboard, String
  key :parent_id, BSON::ObjectID

  timestamps!

  validates_presence_of :chat_room_id, :login
  validates_numericality_of :user_id, :allow_nil => true
  validates_inclusion_of :writeboard, :within => %w{problem}, :allow_nil => true
  validates_true_for :state, :logic => lambda { %w{new uncommited commited}.include?(state) }

  before_save lambda {|u| u.parent.save! unless u.parent.nil?}
  before_save lambda {|u| u.message_updated_at = Time.now if u.message_changed?}

  belongs_to :parent, :class_name => "ChatUpdate"
  many :children, :class_name => "ChatUpdate"

  # -1 second needed as time in database is saved without usec part
  scope :newer_than, lambda {|time| {:updated_at.gte => time.utc - 1.second}}

  scope :with_message_updated_after, lambda {|time|
    {:message_updated_at.gte => time.utc - 1.second}
  }

  scope :not_new, :conditions => {:state => ["uncommited", "commited"]}

  scope :root, :conditions => {:parent_id => nil}

  scope :by_created_at, :order => "created_at"

  def attach_parent!(parent_id)
    new_parent = ChatUpdate.find(parent_id)
    return if new_parent == self.parent || new_parent.nil?

    self.parent = new_parent
    self.parent.children << self unless parent.children.include?(self)
    parent.save!
    save!
  end

  def update_message!(new_message)
    unless new_message == self.message || [new_message, message].all? {|s| s.blank?}
      self.message = new_message
      self.state = "uncommited"
      save!
    end
  end

  def commit_message!(message)
    self.message = message
    self.state = "commited"
    self.writeboard = "problem" if chat_room.problem_rule?
    save!
  end

  def user
    User.find_by_id(user_id)
  end

  def user=(user)
    self.user_id = user.id
    self.login = user.name
  end

  def chat_room=(chat_room)
    self.chat_room_id = chat_room.id
  end

  def chat_room
    ChatRoom.find_by_id(chat_room_id)
  end

  def state
    read_attribute(:state) || "new"
  end
end

