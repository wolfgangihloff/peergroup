class Membership < ActiveRecord::Base
  belongs_to :group
  belongs_to :user

  validates_presence_of :group_id, :user_id
  validates_uniqueness_of :user_id, :scope => :group_id
end
