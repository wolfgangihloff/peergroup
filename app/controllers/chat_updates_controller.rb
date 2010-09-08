class ChatUpdatesController < ApplicationController

  before_filter :require_chat_room

  def create
    @chat_update = ChatUpdate.new(params[:chat_update])
    @chat_update.user = current_user
    @chat_update.chat_room = @chat_room
    @chat_update.save!
    redirect_to chat_room_path(@chat_room)
  end

  def index
    current_user.seen_on_chat!(@chat_room)
    @chat_updates = @chat_room.chat_updates.newer_than(Time.at(params[:last_update].to_i))
  end

  protected

  def require_chat_room
    @chat_room = ChatRoom.find(params[:chat_room_id])
  end
end
