class Group < ActiveRecord::Base

  validates_presence_of :name
  validates_presence_of :description
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => 255
  validates_length_of :description, :maximum => 255

  belongs_to :founder, :class_name => "User"

  has_many :group_members, :autosave => true
  has_many :members, :through => :group_members, :source => :user, :class_name => "User"

  attr_accessible :name, :description

  def add_member!(member)
    gm = group_members.create!(:user => member)
  end

end

