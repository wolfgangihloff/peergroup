require 'csv'

class Group < ActiveRecord::Base

  validates_presence_of :name
  validates_presence_of :description
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => 255
  validates_length_of :description, :maximum => 255

  belongs_to :founder, :class_name => "User"

  has_many :memberships, :autosave => true
  has_many :members, :through => :memberships, :source => :user, :class_name => "User", :order => "users.name"
  has_many :rules, :order => "position"
  has_one :chat_room

  has_friendly_id :name, :use_slug => true

  named_scope :newest, :order => 'created_at desc', :limit => 6

  attr_protected :created_at

  after_create lambda {|group| group.add_member!(group.founder)}
  after_create lambda {|group| ChatRoom.create!(:group => group)}

  after_create :create_default_rules

  def add_member!(member)
    gm = memberships.create!(:user => member)
  end

  def create_default_rules
    path = File.join(Rails.root, "db", "default_rules_#{I18n.locale}.csv")
    reader = CSV.open(path, "r")
    reader.each do |position, name, description, time_limit|
      rules.create!(:position => position, :name => name,
        :description => description, :time_limit => time_limit)
    end
  end
end

