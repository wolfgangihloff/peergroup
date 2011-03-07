class ChatMessage < ActiveRecord::Base
  belongs_to :user
  belongs_to :chat_room

  validates_presence_of :content, :user, :chat_room

  attr_accessible :content

  def publish_to_redis
    channel = "chat:#{chat_room_id}"
    json_string = to_json({
      :only => [:id, :content, :created_at],
      :include => { :user => { :only => [:id, :name], :methods => :avatar_url} }
    })
    REDIS.publish(channel, json_string)
  end

  after_create do |chat_message|
    publish_to_redis
  end
end
