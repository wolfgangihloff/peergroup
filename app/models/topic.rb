class Topic < ActiveRecord::Base
  include SupervisionRedisPublisher

  belongs_to :user
  belongs_to :supervision

  has_many :votes, :as => :statement, :dependent => :destroy

  validates_presence_of :user
  validates_presence_of :supervision

  attr_accessible :content

  after_create do |topic|
    topic.supervision.post_topic
    topic.publish_to_redis
  end

  def supervision_publish_attributes
    {:only => [:id, :content, :user_id]}
  end
end

