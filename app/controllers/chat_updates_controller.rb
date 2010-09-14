class ChatUpdatesController < ApplicationController

  before_filter :require_chat_room

  def create
    @chat_update = initialized_chat_update(params[:chat_update])
    redirect_to chat_room_path(@chat_room)
  end

  def index
    current_user.seen_on_chat!(@chat_room)
    @chat_updates = @chat_room.chat_updates.newer_than(Time.at(params[:last_update].to_i))
  end

  def update
    @chat_update = ChatUpdate.find(params[:id])

    case params[:update_type]
    when "commit"
      @chat_update.commit_message!(params[:chat_update][:message])
      @chat_update = initialized_chat_update
      render :partial => "form", :layout => false
    when "update"
      @chat_update.update_message!(params[:chat_update][:message])
      render :text => 'ok'
    else
      raise "Bad update type: #{params[:update_type].inspect}"
    end
  end

  protected

  def require_chat_room
    @chat_room = ChatRoom.find(params[:chat_room_id])
  end

  def initialized_chat_update(options = {})
    ChatUpdate.new(options).tap do |chat_update|
      chat_update.user = current_user
      chat_update.chat_room = @chat_room
      chat_update.save!
    end
  end
end
