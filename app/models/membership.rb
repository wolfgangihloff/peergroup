class Membership < ActiveRecord::Base
  # TODO use Devise::EMAIL_REGEX when available
  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  belongs_to :group
  belongs_to :user

  validates_presence_of :group, :email
  validates_uniqueness_of :user_id, :scope => :group_id, :allow_nil => true
  validates_uniqueness_of :email, :scope => :group_id
  validates_format_of :email, :with => EMAIL_REGEX

  before_create :assign_user, :unless => :user_id?

  attr_accessible :email

  state_machine do
    after_transition nil => :invited, :do => :send_invitation_email

    event :invite do
      transition nil => :invited
    end

    event :accept do
      transition :invited => :active
    end

    event :verify do
      transition all => :active
    end

    state :active do
      validates_presence_of :user_id
    end
  end

  def assign_user!
    assign_user
    save!
  end

  private

  def send_invitation_email
    if user.blank?
      UserMailer.group_invitation(self).deliver
    end
  end

  def assign_user
    self.user = User.find_by_email(email)
  end
end
