class Idea < ActiveRecord::Base
  belongs_to :user
  belongs_to :supervision, :touch => true

  validates_presence_of :user
  validates_presence_of :supervision
  validates_numericality_of :rating, :allow_nil => true
  validates_presence_of :content

  attr_accessible :content, :rating

  scope :not_rated, :conditions => "rating IS NULL"

  after_update do |idea|
    idea.supervision.post_vote_for_next_step
  end
end

