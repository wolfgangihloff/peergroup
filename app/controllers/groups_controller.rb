class GroupsController < ApplicationController
  before_filter :authenticate

  def index
    @title = t(".title.your_groups", :default => "Your Groups")
    @groups = current_user.groups
  end

  def all
    @title = t(".title.all_groups", :default => "All Groups")
    @groups = Group.all
    render :index
  end

  def new
    @title = t(".title", :default => "New Group")
    @group = current_user.founded_groups.build(params[:group])
  end

  def create
    @group = current_user.founded_groups.build(params[:group])
    if @group.save
      successful_flash("Group Create Successfully")
      redirect_to groups_path
    else
      render :new
    end
  end

  def edit
    @group = current_user.founded_groups.find(params[:id])
  end

  def update
    @group = current_user.founded_groups.find(params[:id])
    if @group.update_attributes(params[:group])
      successful_flash("Group Update successfully")
      redirect_to groups_path
    end
  end

  def show
    @title = t(".title", :default => "Group overview")
    @group = Group.find(params[:id])
  end

  def destroy
    @group = current_user.founded_groups.find(params[:id])
    @group.destroy
    successful_flash("Group Delete Successfully")
    redirect_to groups_path
  end
end
