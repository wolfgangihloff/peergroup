class ChatRoom < ActiveRecord::Base
  belongs_to :group
  belongs_to :leader, :class_name => 'User'
  belongs_to :problem_owner, :class_name => 'User'
  belongs_to :current_rule, :class_name => 'Rule'

  has_many :chat_users

  after_validation :post_rule_update

  def chat_updates
    ChatUpdate.where(:chat_room_id => id)
  end

  def post_rule_update
    if current_rule_id_changed?
      ChatUpdate.create!(:chat_room_id => id, :login => "System",
        :message => "#{current_rule.name} phase starts", :state => "commited")
    end
  end
end
