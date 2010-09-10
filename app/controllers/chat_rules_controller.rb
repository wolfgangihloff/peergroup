class ChatRulesController < ApplicationController
  def index
    @chat_room = ChatRoom.find(params[:chat_room_id])
    render :partial => "chat_rules", :layout => false
  end
end

