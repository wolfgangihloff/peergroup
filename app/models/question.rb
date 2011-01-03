class Question < ActiveRecord::Base
  include SupervisionRedisPublisher

  belongs_to :user
  belongs_to :supervision

  has_one :answer, :dependent => :destroy

  validates_presence_of :user
  validates_presence_of :supervision
  validates_presence_of :content

  attr_accessible :content

  scope :unanswered, where('(SELECT count(*) FROM answers WHERE answers.question_id = questions.id) = 0')

  after_create do |question|
    question.publish_to_redis
  end

  def supervision_publish_attributes
    {:only => [:id, :content, :user_id]}
  end
end

