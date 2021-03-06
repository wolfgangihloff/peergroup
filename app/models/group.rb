require 'csv'

class Group < ActiveRecord::Base
  has_many :memberships, :autosave => true, :dependent => :destroy
  has_many :invited_memberships, :class_name => "Membership", :conditions => {:memberships => {:state => "invited"}}
  has_many :requested_memberships, :class_name => "Membership", :conditions => {:memberships => {:state => "requested"}}
  has_many :active_memberships, :class_name => "Membership", :conditions => {:memberships => {:state => "active"}}
  has_many :members, :through => :memberships, :source => :user, :class_name => "User", :order => "users.name"
  has_many :active_members, :source => :user, :through => :active_memberships
  has_many :invited_members, :source => :user, :through => :invited_memberships
  has_many :requested_members, :source => :user, :through => :requested_memberships
  has_many :supervisions, :dependent => :destroy, :extend => GroupSupervisionsExtension
  has_many :chat_rooms, :dependent => :destroy
  has_one :chat_room, :conditions => {:supervision_id => nil}
  belongs_to :founder, :class_name => "User"

  validates :name, :presence => true, :uniqueness => true, :length => {:maximum => 255}
  validates :description, :length => {:maximum => 255}
  validates :founder, :presence => true

  has_friendly_id :name, :use_slug => true

  scope :newest, :order => 'created_at desc', :limit => 6
  scope :closed, where(:closed => true)
  scope :open, where(:closed => false)

  after_create :add_founder_to_members, :create_chat_room
  after_update :accept_pending_requests, :if => :group_opened?

  attr_accessible :name, :description, :closed

  def to_s
    name
  end

  def public?
    not closed?
  end

  def add_member!(member)
    memberships.create!(:email => member.email).verify!
  end

  def founded_by?(user)
    founder == user
  end

  def set_redis_access_for_user(user, token = SecureRandom.hex)
    REDIS.setex("group:#{id}:token:#{token}", 60, user.id)
    token
  end

  private

  def add_founder_to_members
    add_member!(founder)
  end

  def group_opened?
    closed_changed? and public?
  end

  def accept_pending_requests
    requested_memberships.each(&:accept!)
  end
end
