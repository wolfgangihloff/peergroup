class ChattingUsersController < ApplicationController
  def index
    render :partial => "chatting_users", :object => User.chatting, :layout => false
  end
end

