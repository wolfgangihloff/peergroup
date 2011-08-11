class ChatMessage < ActiveRecord::Base
  belongs_to :user
  belongs_to :chat_room

  validates_presence_of :content, :user, :chat_room

  attr_accessible :content

  scope :recent, lambda { where(["created_at >= ?", 1.day.ago]) }

  def publish_to_redis
    channel = "chat:#{chat_room_id}"
    json_string = to_json({
      :only => [:id, :content, :created_at],
      :include => { :user => { :only => [:id, :name], :methods => :avatar_url} }
    })
    REDIS.publish(channel, json_string)
  end

  def ping_user
    REDIS.publish("chat_activity:#{chat_room_id}:user:#{user.id}", "available:#{DateTime.now.to_time.to_i}")
  end

  after_create do |chat_message|
    publish_to_redis
    ping_user
  end
end
