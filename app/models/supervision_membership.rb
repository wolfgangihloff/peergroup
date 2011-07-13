class SupervisionMembership < ActiveRecord::Base
  belongs_to :supervision
  belongs_to :user

  validates_presence_of :supervision, :user
  validates_uniqueness_of :user_id, :scope => :supervision_id

  delegate :join_member, :remove_member, :to => :supervision, :prefix => true

  after_create :supervision_join_member
  after_destroy :supervision_remove_member
end
