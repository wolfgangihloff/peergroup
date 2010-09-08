class Group < ActiveRecord::Base

  validates_presence_of :name
  validates_presence_of :description
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => 255
  validates_length_of :description, :maximum => 255

  belongs_to :founder, :class_name => "User"

  has_many :memberships, :autosave => true
  has_many :members, :through => :memberships, :source => :user, :class_name => "User", :order => "users.name"
  has_one :chat_room

  attr_accessible :name, :description

  after_create lambda {|group| group.add_member!(group.founder)}
  after_create lambda {|group| ChatRoom.create!(:group => group)}

  def add_member!(member)
    gm = memberships.create!(:user => member)
  end

end

