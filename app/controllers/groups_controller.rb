class GroupsController < ApplicationController
  before_filter :authenticate
  before_filter :fetch_chat, :only => [:show]
  before_filter :filters, :only => [:index]

  def index
    @title = t(".title.all_groups", :default => "All Groups")
    @user_groups = current_user.groups
    @groups = Group.order("#{sort_method} #{sort_direction}").paginate(:page => params[:page], :per_page => 10)
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

  def filters
    @filters ||= ["date", "membership", "name"]
  end

  def sort_method
    @methods = {:membership => "(SELECT COUNT(group_id) FROM memberships WHERE group_id = groups.id)", :name => "name"}
    @methods.has_key?(params[:filter].try(:to_sym)) ? @methods[params[:filter].to_sym] : "created_at"
  end

  def sort_direction
    params[:direction].try(:upcase) == "ASC" ? "ASC" : "DESC"
  end
end
