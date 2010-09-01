class ChatRoomsController < ApplicationController

  def index
    @chat_updates = ChatUpdate.all
    current_user.seen_on_chat!
  end

end
