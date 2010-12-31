class Idea < ActiveRecord::Base
  belongs_to :user
  belongs_to :supervision

  validates_presence_of :user
  validates_presence_of :supervision
  validates_numericality_of :rating, :allow_nil => true, :only_integer => true
  validates_inclusion_of :rating, :allow_nil => true, :in => 1..5
  validates_presence_of :content

  attr_accessible :content, :rating

  scope :not_rated, :conditions => "rating IS NULL"

  after_create do |idea|
    idea.supervision.post_idea(idea)
  end

  after_update do |idea|
    idea.supervision.post_vote_for_next_step(idea)
  end
end

