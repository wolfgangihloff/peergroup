class GroupsController < ApplicationController
  before_filter :authenticate
  before_filter :fetch_chat, :only => [:show]
  def index
    @title = t(".title.your_groups", :default => "Your Groups")
    @groups = current_user.groups
  end

  def all
    @title = t(".title.all_groups", :default => "All Groups")
    @groups = Group.all
    render :index
  end

  def show
    @title = t(".title", :default => "Group overview")
  end

  protected

  def fetch_chat
    @group = Group.find(params[:id])
    @chat_room ||= @group.chat_room
    @chat_messages = @chat_room.chat_messages.recent
    @token = @chat_room.set_redis_access_token_for_user(current_user)
  end
end
