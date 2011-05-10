class SupervisionMembership < ActiveRecord::Base
  belongs_to :supervision
  belongs_to :user

  validates_presence_of :supervision
  validates_presence_of :user
  validates_uniqueness_of :user_id, :scope => :supervision_id

  after_create do
    supervision.join_member
    publish_to_redis
  end

  after_destroy do
    supervision.remove_member
    publish_to_redis
  end

  def publish_to_redis
    channel = "supervision:#{supervision_id}"
    json_string = to_json({
      :only => [],
      :methods => :status,
      :include => { :user => { :only => [:id, :name], :methods => :avatar_url} }
    });
    REDIS.publish(channel, json_string)
  end

  def status
    destroyed? ? "destroyed" : "created"
  end
end
