class ChatUsersController < ApplicationController
  def index
    @chat_room = ChatRoom.find(params[:chat_room_id])
    users = User.beeing_in_chat_room(@chat_room)
    render :partial => "chat_users", :object => users, :layout => false
  end
end

