require "supervision_redis_publisher"

class Answer < ActiveRecord::Base
  include SupervisionRedisPublisher

  belongs_to :user
  belongs_to :question

  validates_presence_of :user
  validates_presence_of :question
  validates_presence_of :content

  attr_accessible :content

  after_create do |answer|
    answer.supervision.post_vote_for_next_step
    answer.publish_to_redis
  end

  delegate :supervision, :supervision_id, :to => :question

  def supervision_publish_attributes
    {:only => [:id, :content, :question_id, :user_id]}
  end
end

