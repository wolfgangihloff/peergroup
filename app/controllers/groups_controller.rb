class GroupsController < ApplicationController
  before_filter :authenticate, :except => [:all_groups]
  
  def index
    @groups = params[:all] ? Group.all : current_user.groups
    flash[:notice] = "There are no groups here." if @groups.empty?
  end

  def new
    @title = "New Group"
    @group = Group.new
  end

  def create
    @group = Group.new(params[:group])
    @group.founder = current_user

    if @group.save
      flash[:notice] = "Group Create Successfully"
      redirect_to groups_path
    else
      render :action => "new"
    end
  end

  def edit
    @group = Group.find(:first, :conditions => "id = #{params[:id]}")
  end

  def update
    @group = Group.find(:first, :conditions => "id = #{params[:id]}")
    if @group.update_attributes(params[:group])
      flash[:notice] = "Group Update successfully" 
      redirect_to groups_path
    end
  end

  def destroy
    @group = Group.find(:first, :conditions => "id = #{params[:id]}")
    @user_group = GroupsUser.find(:first,:conditions=>["group_id=? and user_id=?",params[:id],current_user.id])

    @group.destroy if @user_group.group.user_id == current_user.id

    flash[:notice] = "Group Delete Successfully"
    redirect_to groups_path
  end
    
  def join_group
    @group = GroupsUser.find(:first,:conditions=>["user_id=? and group_id=?",current_user.id,params[:id].to_i])
    if @group
      flash[:notice] = "You have already Joined This Group.."
      redirect_to groups_path
    else
      flash[:notice] = "New Group is added"
      @group_user = GroupsUser.new
      @group_user.group_id = params[:id]
      @group_user.user_id = current_user.id
      @group_user.save
      redirect_to groups_path
    end
  end
  
  def invite
  end
end
