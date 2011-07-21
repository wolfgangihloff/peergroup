class SupervisionMembership < ActiveRecord::Base
  belongs_to :supervision
  belongs_to :user

  validates_presence_of :supervision, :user
  validates_uniqueness_of :user_id, :scope => :supervision_id
  validate :supervision_in_progress_state, :if => :supervision

  delegate :join_member, :remove_member, :to => :supervision, :prefix => true

  after_create :supervision_join_member
  after_destroy :supervision_remove_member

  private

  def supervision_in_progress_state
    errors.add :supervision, :not_in_progress_state unless supervision.in_progress?
  end
end
