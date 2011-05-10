class GroupsController < ApplicationController
  before_filter :authenticate
  before_filter :require_group, :except => [:index, :new, :create]

  # TODO: fix permissions for group founder

  def index
    if params[:user_id].present?
      @title = t(".title.your_groups", :default => "Your Groups")
      @groups = current_user.groups
    else
      @title = t(".title.all_groups", :default => "All Groups")
      @groups = Group.all
    end
  end

  def new
    @title = t(".title", :default => "New Group")
    @group = Group.new
  end

  def create
    @group = Group.new(params[:group])
    @group.founder = current_user

    if @group.save
      successful_flash("Group Create Successfully")
      redirect_to groups_path
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @group.update_attributes(params[:group])
      successful_flash("Group Update successfully")
      redirect_to groups_path
    end
  end

  def show
  end

  # FIXME: temporary fix
  def destroy
    @group.destroy if @group.founder == current_user
    successful_flash("Group Delete Successfully")
    redirect_to groups_path
  end

  def current_supervision
    if @group.current_supervision
      redirect_to supervision_path(@group.current_supervision)
    else
      redirect_to new_group_supervision_path(@group)
    end
  end

  protected

  def require_group
    @group = Group.find(params[:id])
  end
end
