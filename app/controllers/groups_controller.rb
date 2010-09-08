class GroupsController < ApplicationController
  before_filter :authenticate
  before_filter :require_group, :except => [:index, :new, :create]

  def index
    @groups = params[:all] ? Group.all : current_user.groups
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
  end

  def update
    if @group.update_attributes(params[:group])
      flash[:notice] = "Group Update successfully" 
      redirect_to groups_path
    end
  end

  def show
  end

  def destroy
    @user_group = GroupsUser.find(:first,:conditions=>["group_id=? and user_id=?",params[:id],current_user.id])

    @group.destroy if @user_group.group.user_id == current_user.id

    flash[:notice] = "Group Delete Successfully"
    redirect_to groups_path
  end

  protected

  def require_group
    @group = Group.find(params[:id])
  end
end
