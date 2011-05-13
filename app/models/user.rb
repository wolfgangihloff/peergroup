require "digest/md5"

class User < ActiveRecord::Base
  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  include User::Authentication

  has_many :relationships, :foreign_key => "follower_id", :dependent => :destroy
  has_many :following, :through => :relationships, :source => :followed
  has_many :reverse_relationships, :foreign_key => "followed_id",
    :class_name => "Relationship",
    :dependent => :destroy
  has_many :followers, :through => :reverse_relationships, :source => :follower
  has_many :memberships
  has_many :groups, :through => :memberships
  has_many :founded_groups, :class_name => "Group", :foreign_key => "founder_id"
  has_many :votes
  has_many :supervision_memberships
  has_many :supervisions, :through => :supervision_memberships

  validates_presence_of :name, :email
  validates_length_of   :name, :maximum => 50
  validates_format_of   :email, :with => EMAIL_REGEX
  validates_uniqueness_of :email, :case_sensitive => false

  attr_accessible :name, :email, :password, :password_confirmation

  def following?(followed)
    relationships.find_by_followed_id(followed)
  end

  def follow!(followed)
    relationships.create!(:followed_id => followed.id)
  end

  def unfollow!(followed)
    relationships.find_by_followed_id(followed).destroy
  end

  def to_s
    name
  end

  def member_of?(group)
    groups.exists?(group.id)
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

  def join_group(group)
    groups << group
  end

  # TODO throw away gravatar gem, it's not as hard to implement it by ourselves,
  # and with our own implementation we can use this url in other parts, not only
  # in views
  def avatar_url(options = {})
    base_url = if options[:ssl]
                 "https://secure.gravatar.com/avatar/"
               else
                 "http://www.gravatar.com/avatar/"
               end
    email_digest = Digest::MD5.hexdigest(email)
    "#{base_url}#{email_digest}"
  end
end
