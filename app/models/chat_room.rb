class ChatRoom < ActiveRecord::Base
  belongs_to :group
  belongs_to :leader, :class_name => 'User'
  belongs_to :problem_owner, :class_name => 'User'

  validates_presence_of :group

  has_many :chat_messages, :dependent => :destroy, :order => "created_at DESC"

  attr_accessible

end
