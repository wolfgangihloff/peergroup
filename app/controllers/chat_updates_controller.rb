class ChatUpdatesController < ApplicationController
  def create
    @chat_update = ChatUpdate.new(params[:chat_update])
    @chat_update.user = current_user
    @chat_update.save!
    redirect_to chat_rooms_path
  end

  def index
    current_user.seen_on_chat!
    @chat_updates = ChatUpdate.newer_than(Time.at(params[:last_update].to_i))
  end
end
