class ChatUpdatesController < ApplicationController
  include ChatUpdatesInitializer

  before_filter :require_chat_room

  def index
    @chat_updates = @chat_room.chat_updates.newer_than(Time.at(params[:last_update].to_i)).not_new.root.by_created_at
    current_user.seen_on_chat!(@chat_room)
  end

  def new
    @chat_update = initialized_chat_update
    @chat_update.attach_parent!(params[:parent_id]) unless params[:parent_id].blank?
    render :partial => "form", :layout => false
  end

  def update
    raise "Bad update type: #{params[:update_type].inspect}" unless
      %w{commit update}.include?(params[:update_type])

    @chat_update = ChatUpdate.find(params[:id])
    @chat_update.send("#{params[:update_type]}_message!", params[:chat_update][:message])
    render :nothing => true
  end

  protected

  def require_chat_room
    @chat_room = ChatRoom.find(params[:chat_room_id])
  end

end

