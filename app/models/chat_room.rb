class ChatRoom < ActiveRecord::Base
  belongs_to :group
  belongs_to :leader, :class_name => 'User'
  belongs_to :problem_owner, :class_name => 'User'
  # Unused as I see, so commented, can be restored if it is every used
  #belongs_to :current_rule, :class_name => 'Rule'

  validates_presence_of :group

  has_many :chat_messages, :dependent => :destroy, :order => "created_at DESC"

  attr_accessible

end
