require "digest/md5"

class User < ActiveRecord::Base
  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  include User::Authentication

  has_many :relationships, :foreign_key => "follower_id", :dependent => :destroy
  has_many :following, :through => :relationships, :source => :followed
  has_many :reverse_relationships, :foreign_key => "followed_id",
    :class_name => "Relationship", :dependent => :destroy
  has_many :followers, :through => :reverse_relationships, :source => :follower
  has_many :memberships, :dependent => :destroy
  has_many :invited_memberships, :class_name => "Membership", :conditions => {:memberships => {:state => "invited"}}
  has_many :requested_memberships, :class_name => "Membership", :conditions => {:memberships => {:state => "requested"}}
  has_many :active_memberships, :class_name => "Membership", :conditions => {:memberships => {:state => "active"}}
  has_many :groups, :through => :memberships
  has_many :active_groups, :source => :group, :through => :active_memberships
  has_many :invited_groups, :source => :group, :through => :invited_memberships
  has_many :requested_groups, :source => :group, :through => :requested_memberships
  has_many :founded_groups, :class_name => "Group", :foreign_key => "founder_id"
  has_many :votes
  has_many :supervision_memberships
  has_many :supervisions, :through => :supervision_memberships

  validates_presence_of :name, :email
  validates_length_of   :name, :maximum => 50
  validates_format_of   :email, :with => EMAIL_REGEX
  validates_uniqueness_of :email, :case_sensitive => false

  attr_accessible :name, :email, :password, :password_confirmation

  after_create :associate_group_memberships

  scope :without, lambda { |user| where(["users.id != ?", user]) }

  def to_s
    name
  end

  def following?(followed)
    relationships.find_by_followed_id(followed)
  end

  def follow!(followed)
    relationships.create!(:followed_id => followed.id)
  end

  def unfollow!(followed)
    relationships.find_by_followed_id(followed).destroy
  end

  def active_member_of?(group)
    active_groups.exists?(group)
  end

  def invited_member_of?(group)
    invited_groups.exists?(group)
  end

  def requested_member_of?(group)
    requested_groups.exists?(group)
  end

  def join_supervision(supervision)
    supervisions << supervision
  end

  def leave_supervision(supervision)
    supervision_memberships.where(:supervision_id => supervision.id).destroy_all
  end

  def member_of_supervision?(supervision)
    supervisions.exists?(supervision.id)
  end

  def avatar_url(options = {})
    options[:size] ||= 50
    options[:rating] ||= "PG"
    params = options.map { |k, v| "#{k}=#{v}" }.join("&")
    email_digest = Digest::MD5.hexdigest(email)
    "http://www.gravatar.com/avatar/" + email_digest + "?#{params}"
  end

  private

  def associate_group_memberships
    Membership.invited.where(:email => email).each(&:assign_user!)
  end
end
