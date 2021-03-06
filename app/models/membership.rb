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

  scope :invited, where(:state => "invited")
  scope :requested, where(:state => "requested")

  state_machine do
    after_transition nil => :invited, :do => :send_invitation_email
    after_transition nil => :requested, :do => :send_request_email

    event :invite do
      transition nil => :invited
    end

    event :request do
      transition nil => :requested
    end

    event :accept do
      transition [:invited, :requested] => :active
    end

    event :verify do
      transition all => :active
    end

    state :requested do
      validates_presence_of :user_id
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
    UserMailer.group_invitation(self).deliver
  end

  def send_request_email
    UserMailer.group_request(self).deliver
  end

  def assign_user
    self.user = User.find_by_email(email)
  end
end
