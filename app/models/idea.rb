class Idea < ActiveRecord::Base
  validates_presence_of :user, :user_id
  validates_presence_of :content
  validates_presence_of :supervision, :supervision_id

  validates_numericality_of :rating, :allow_nil => true

  belongs_to :user
  belongs_to :supervision

  scope :not_rated, :conditions => "rating IS NULL"
end

