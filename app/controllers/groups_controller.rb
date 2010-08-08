class GroupsController < ApplicationController
  before_filter :authenticate, :except => [:all_groups]
  
  def index
    @group = Group.find(:all,:conditions => "user_id = #{current_user.id} ")
    if @group.blank?
      flash[:notice] = "User has not Created any Group"
    end
  end

  def new
    @group = Group.new
  end

  def all_groups
    @groups = Group.find(:all)
  end

  def create
    @group = Group.new(params[:group])
	@user_group = GroupsUser.new
	
    @group.user_id = current_user.id
    if @group.save
	  @user_group.group_id = @group.id
	  @user_group.user_id = current_user.id
	  @user_group.save
      flash[:notice] = "Group Create Successfully"
      redirect_to groups_path
    else
      #render :action => "new"
      #redirect_to new_group_path
      # redirect_to @group
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
    else
    
    end

  end

  def destroy
    @group = Group.find(:first, :conditions => "id = #{params[:id]}")
    @user_group = GroupsUser.find(:first,:conditions=>["group_id=? and user_id=?",params[:id],current_user.id])
	if @user_group.group.user_id == current_user.id
		@group.destroy
	end
    @user_group
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
