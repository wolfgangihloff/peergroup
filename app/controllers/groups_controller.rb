class GroupsController < ApplicationController
  before_filter :authenticate, :except => [:show, :new, :create]
  # before_filter :correct_user, :only => [:edit, :update]
  # before_filter :admin_user,   :only => :destroy

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
    @group.user_id = current_user.id
    if @group.save
      # redirect_to @group
      redirect_to groups_path
    else
      #render :action => "new"
      #redirect_to new_group_path
      # redirect_to @group
    end
  end

  def edit
    #params[:data] = controller.action_name
    #exit
    @group = Group.find(:first, :conditions => "id = #{params[:id]}")
  end

  def update
    @group = Group.find(:first, :conditions => "id = #{params[:id]}")
    if @group.update_attributes(params[:group])
      redirect_to groups_path
    else
    
    end

  end

  def destroy
    @group = Group.find(:first, :conditions => "id = #{params[:id]}")
    @group.destroy
    redirect_to groups_path
  end

  def invite

  end





end
