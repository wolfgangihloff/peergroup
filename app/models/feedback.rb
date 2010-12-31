class Feedback < ActiveRecord::Base
  belongs_to :user
  belongs_to :supervision

  validates_presence_of :user
  validates_presence_of :supervision
  validates_presence_of :content

  attr_accessible :content
end
