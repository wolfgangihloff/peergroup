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
    json_string = {:message => {
      :status => "available",
      :id => user.id,
      :timestamp => DateTime.now.to_time.to_i
    } }.to_json
    REDIS.publish("activity:#{chat_room_id}", json_string )
    REDIS.setex("activity:#{chat_room_id}:user:#{user.id}", 60, "available")
  end

  after_create do |chat_message|
    publish_to_redis
    ping_user
  end
end
