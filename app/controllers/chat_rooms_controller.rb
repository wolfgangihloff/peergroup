class ChatRoomsController < ApplicationController

  before_filter :require_user, :only => [:select_leader, :select_problem_owner]
  before_filter :require_chat_room

  def show
    @users_on_chat = User.beeing_in_chat_room(@chat_room)
    current_user.seen_on_chat!(@chat_room)
  end

  def select_leader
    @chat_room.update_attributes!(:leader => @user)
    redirect_to @chat_room
  end

  def select_problem_owner
    @chat_room.update_attributes!(:problem_owner => @user)
    redirect_to @chat_room
  end

  protected

  def require_user
    @user = User.find(params[:user_id])
  end

  def require_chat_room
    @chat_room = ChatRoom.find(params[:id])
  end
end
