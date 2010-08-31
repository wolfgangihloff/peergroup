class ChatRoomsController < ApplicationController

  def index
    @chat_updates = ChatUpdate.all
  end

end
