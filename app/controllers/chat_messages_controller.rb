class ChatMessagesController < ApplicationController

  before_filter :authenticate
  before_filter :fetch_chat_room


  def create
    @chat_message = @chat_room.chat_messages.build(params[:chat_message]) do |chat_message|
      chat_message.user = current_user
    end
    respond_to do |format|
      if @chat_message.save
        format.js { render :json => @chat_message, :status => :created }
        format.html { redirect_to(@chat_room) }
      else
        format.js { render :json => @chat_message, :status => :error }
        format.html { redirect_to(@chat_room) }
      end
    end
  end

  protected

  def fetch_chat_room
    @chat_room = ChatRoom.find(params[:chat_room_id])
  end

end
