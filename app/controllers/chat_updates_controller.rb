class ChatUpdatesController < ApplicationController
  def create
    @chat_update = ChatUpdate.new(params[:chat_update])
    @chat_update.user = current_user
    @chat_update.save!
    redirect_to chat_rooms_path
  end
end
