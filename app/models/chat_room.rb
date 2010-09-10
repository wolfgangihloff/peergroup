class ChatRoom < ActiveRecord::Base
  belongs_to :group
  belongs_to :leader, :class_name => 'User'
  belongs_to :problem_owner, :class_name => 'User'
  belongs_to :current_rule, :class_name => 'Rule'

  after_validation :post_rule_update

  def chat_updates
    ChatUpdate.where(:chat_room_id => id)
  end

  def post_rule_update
    ChatUpdate.create!(:chat_room_id => id, :login => "System",
      :message => "#{current_rule.name} phase starts") if current_rule_id_changed?
  end
end
