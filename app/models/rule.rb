class Rule < ActiveRecord::Base

  validates_presence_of :name, :description
  validates_presence_of :group, :group_id
  validates_length_of :name, :maximum => 255
  validates_numericality_of :time_limit

  belongs_to :group

  has_one :chat_room, :foreign_key => "current_rule_id", :dependent => :nullify

  acts_as_list :scope => :group
end
