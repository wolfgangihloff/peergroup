class ChatMessage < ActiveRecord::Base
  belongs_to :user
  belongs_to :chat_room

  validates_presence_of :content, :user, :chat_room

  attr_accessible :content
end
