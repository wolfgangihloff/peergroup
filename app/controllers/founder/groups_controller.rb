class Founder::GroupsController < ApplicationController
  before_filter :authenticate

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
end
