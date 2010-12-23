class ChatRoomsController < ApplicationController
  before_filter :authenticate
  before_filter :fetch_chat_room

  def show
    @chat_messages = @chat_room.chat_messages.limit(25)
    @token = SecureRandom.hex
    REDIS.setex("chat:#{@chat_room.id}:users:#{current_user.id}:token:#{@token}", 60, "1")
  end

  def select_leader
    @user = @chat_room.group.users.find(params[:user_id])
    @chat_room.leader = @user
    @chat_room.save!
    render :nothing => true
  end

  def select_problem_owner
    @user = @chat_room.group.users.find(params[:user_id])
    @chat_room.problem_owner = @user
    @chat_room.save!
    render :nothing => true
  end

  protected

  def fetch_chat_room
    @chat_room = ChatRoom.find(params[:id])
  end
end

