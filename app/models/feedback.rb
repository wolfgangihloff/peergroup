class Feedback < ActiveRecord::Base
  belongs_to :user
  belongs_to :supervision

  validates_presence_of :user, :supervision, :content

  attr_accessible :content
end
