class Membership < ActiveRecord::Base

  validates_presence_of :group_id, :user_id

  validates_uniqueness_of :user_id, :scope => :group_id

  belongs_to :group
  belongs_to :user

end
