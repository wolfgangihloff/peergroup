class Membership < ActiveRecord::Base
  # TODO use Devise::EMAIL_REGEX when available
  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  belongs_to :group
  belongs_to :user

  validates_presence_of :group, :email
  validates_uniqueness_of :user_id, :scope => :group_id, :allow_nil => true
  validates_uniqueness_of :email, :scope => :group_id
  validates_format_of :email, :with => EMAIL_REGEX

  before_create :assign_user_by_email, :unless => :user_id?

  attr_accessible :email

  private

  def assign_user_by_email
    self.user = User.find_by_email(email)
  end
end
