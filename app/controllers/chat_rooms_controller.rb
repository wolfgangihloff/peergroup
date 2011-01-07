class ChatRoomsController < ApplicationController
  before_filter :authenticate
  before_filter :fetch_group
  before_filter :fetch_chat_room

  def show
    @chat_messages = @chat_room.chat_messages.limit(25)
    @token = SecureRandom.hex
    REDIS.setex("chat:#{@chat_room.id}:users:#{current_user.id}:token:#{@token}", 60, "1")
  end

  protected

  def fetch_group
    @group = current_user.groups.find(params[:group_id])
  end

  def fetch_chat_room
    @chat_room = @group.chat_room
  end
end

