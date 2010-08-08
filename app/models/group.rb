class Group < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :description
  has_many :groups_user
  has_many :users, :through => :groups_user
end
