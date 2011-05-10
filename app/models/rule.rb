class Rule < ActiveRecord::Base
  belongs_to :group
  has_one :chat_room, :foreign_key => "current_rule_id", :dependent => :nullify

  validates_presence_of :name, :description, :group, :group_id
  validates_length_of :name, :maximum => 255
  validates_numericality_of :time_limit
end
