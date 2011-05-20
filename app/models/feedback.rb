class Feedback < ActiveRecord::Base
  belongs_to :user
  belongs_to :supervision

  validates_presence_of :user, :supervision, :contact

  attr_accessible :content
end
