class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  attr_accessor :passcode

  has_many :memberships, :dependent => :destroy
  has_many :invited_memberships, :class_name => "Membership", :conditions => {:memberships => {:state => "invited"}}
  has_many :requested_memberships, :class_name => "Membership", :conditions => {:memberships => {:state => "requested"}}
  has_many :active_memberships, :class_name => "Membership", :conditions => {:memberships => {:state => "active"}}
  has_many :groups, :through => :active_memberships
  has_many :active_groups, :source => :group, :through => :active_memberships
  has_many :invited_groups, :source => :group, :through => :invited_memberships
  has_many :requested_groups, :source => :group, :through => :requested_memberships
  has_many :founded_groups, :class_name => "Group", :foreign_key => "founder_id"
  has_many :votes
  has_many :supervision_memberships
  has_many :supervisions, :through => :supervision_memberships

  validates_presence_of :name
  validates_length_of   :name, :maximum => 50
  validates_uniqueness_of :email, :case_sensitive => false

  attr_accessible :name, :email, :password, :password_confirmation, :remember_me

  after_create :associate_group_memberships

  scope :without, lambda { |user| where(["users.id != ?", user]) }

  def to_s
    name
  end

  def show_email?
    show_email == true
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
    supervisions << supervision unless supervisions.include?(supervision)
  end

  def leave_supervision(supervision)
    supervision_memberships.where(:supervision_id => supervision.id).destroy_all
  end

  def member_of_supervision?(supervision)
    supervisions.exists?(supervision.id)
  end

  def last_proposed_topic(group)
    @supervision = self.supervision_memberships.select{|s| s.supervision.try(:group_id) == group.id && s.supervision.finished? == true }.last.try(:supervision)
    return Topic.new if @supervision.nil?
    Topic.where(:user_id => self.id, :supervision_id => @supervision.id).where("`topics`.id != ?", @supervision.topic_id).first || Topic.new
  end

  def avatar_url(options = {})
    options[:size] ||= 50
    options[:rating] ||= "PG"
    options[:d] ||= "identicon"
    params = options.map { |k, v| "#{k}=#{v}" }.join("&")
    email_digest = Digest::MD5.hexdigest(email)
    "http://www.gravatar.com/avatar/" + email_digest + "?#{params}"
  end

  def gravatar_profile_url
    email_digest = Digest::MD5.hexdigest(email)
    "http://www.gravatar.com/" + email_digest
  end

  def chat_status(chat_room)
    @status = REDIS.get("activity:#{chat_room}:user:#{self.id}")
    return :unavailable unless @status
    @status.split(":")[0].to_sym
  end

  def ping
    REDIS.setex("user:#{self.id}:active", 60, true)
  end

  def online?
    REDIS.exists("user:#{self.id}:active")
  end

  def generate_group_subscription_tokens
    @tokens = []
    self.groups.each do |group|
      @tokens << [group.set_redis_access_for_user(self), group.id].join(":")
    end
    @tokens.join(",")
  end

  private

  def associate_group_memberships
    Membership.invited.where(:email => email).each(&:assign_user!)
  end
end
