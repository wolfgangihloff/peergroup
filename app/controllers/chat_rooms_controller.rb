class ChatRoomsController < ApplicationController
  include ChatUpdatesInitializer

  before_filter :require_user, :only => [:select_leader, :select_problem_owner]
  before_filter :require_chat_room

  def show
    @users_on_chat = User.beeing_in_chat_room(@chat_room)
    @chat_update = initialized_chat_update
    current_user.seen_on_chat!(@chat_room)
  end

  def select_leader
    @chat_room.leader = @user
    @chat_room.save!
    redirect_to @chat_room
  end

  def select_problem_owner
    @chat_room.problem_owner = @user
    @chat_room.save!
    redirect_to @chat_room
  end

  def select_current_rule
    @chat_room.current_rule = Rule.find(params[:rule_id])
    @chat_room.save!
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
