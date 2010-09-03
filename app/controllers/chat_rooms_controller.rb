class ChatRoomsController < ApplicationController

  def show
    @chat_room = ChatRoom.find(params[:id])
    current_user.seen_on_chat!
  end

end
