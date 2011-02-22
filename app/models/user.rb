class User < ActiveRecord::Base
  concerned_with :authentication

  attr_accessible :name, :email, :password, :password_confirmation

  has_many :relationships, :foreign_key => "follower_id", :dependent => :destroy
  has_many :following, :through => :relationships, :source => :followed
  has_many :reverse_relationships, :foreign_key => "followed_id",
    :class_name => "Relationship",
    :dependent => :destroy
  has_many :followers, :through => :reverse_relationships, :source => :follower

  has_many :memberships
  has_many :groups, :through => :memberships

  has_many :founded_groups, :class_name => "Group"

  has_many :votes

  has_many :supervision_memberships
  has_many :supervisions, :through => :supervision_memberships

  EmailRegex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates_presence_of :name, :email
  validates_length_of   :name, :maximum => 50
  validates_format_of   :email, :with => EmailRegex
  validates_uniqueness_of :email, :case_sensitive => false

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

end
