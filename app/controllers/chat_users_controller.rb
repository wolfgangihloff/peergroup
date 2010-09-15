class ChatUsersController < ApplicationController

  def index
    @chat_room = ChatRoom.find(params[:chat_room_id])
    @chat_users = @chat_room.chat_users.present.by_username
    render :partial => "chat_users", :layout => false
  end
end

