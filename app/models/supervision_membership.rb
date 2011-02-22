class SupervisionMembership < ActiveRecord::Base
  belongs_to :supervision
  belongs_to :user

  validates_presence_of :supervision
  validates_presence_of :user
  validates_uniqueness_of :user_id, :scope => :supervision_id

  after_create do
    supervision.join_member
  end

  after_destroy do
    supervision.remove_member
  end
end
