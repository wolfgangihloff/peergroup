class ChatMessage < ActiveRecord::Base
  belongs_to :user
  belongs_to :chat_room

  validates_presence_of :content, :user, :chat_room

  attr_accessible :content

  after_create do |chat_message|
    redis_channel = "chat:#{chat_message.chat_room_id}:message"
    redis_message = "#{chat_message.user_id}:#{chat_message.created_at.to_i}:#{chat_message.id}:#{chat_message.content}"
    REDIS.publish(redis_channel, redis_message)
  end
end
