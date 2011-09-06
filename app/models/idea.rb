class Idea < ActiveRecord::Base
  include SupervisionRedisPublisher

  belongs_to :user
  belongs_to :supervision

  validates_presence_of :user
  validates_presence_of :supervision
  validates_numericality_of :rating, :allow_nil => true, :only_integer => true
  validates_inclusion_of :rating, :allow_nil => true, :in => 1..5
  validates_presence_of :content

  attr_accessible :content, :rating

  scope :not_rated, where("`ideas`.rating IS NULL")

  after_create do
    publish_to_redis
  end

  after_update do
    supervision.post_vote_for_next_step
    publish_to_redis
  end

  def supervision_publish_attributes
    {:only => [:id, :content, :rating, :user_id]}
  end

end
