class ChatRoomsController < ApplicationController

  def show
    @chat_room = ChatRoom.find(params[:id])
    @users_on_chat = User.beeing_in_chat_room(@chat_room)
    current_user.seen_on_chat!(@chat_room)
  end

end
