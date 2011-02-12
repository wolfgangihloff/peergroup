class ChatRoom < ActiveRecord::Base
  belongs_to :group
  belongs_to :supervision
  belongs_to :leader, :class_name => 'User'
  belongs_to :problem_owner, :class_name => 'User'

  validates_presence_of :group

  has_many :chat_messages, :dependent => :destroy, :order => "created_at DESC"

  before_validation :assign_group_from_supervision

  attr_accessible

  protected

  def assign_group_from_supervision
    self.group = supervision.group if supervision.present?
  end

  def last_messages
    chat_messages.limit(25)
  end

end
