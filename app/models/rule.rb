class Rule < ActiveRecord::Base

  validates_presence_of :name, :description
  validates_presence_of :group, :group_id
  validates_length_of :name, :maximum => 255
  validates_numericality_of :position, :time_limit

  belongs_to :group

  acts_as_list :scope => :group
end
