class InvitationsController < ApplicationController
  before_filter :authenticate

  def index
    group
  end

  def new
    @membership = group.memberships.build(params[:membership])
  end

  def create
    @membership = group.memberships.build(params[:membership])
    if @membership.save
      redirect_to group_invitations_path(group), :notice => "User invited"
    else
      render :new
    end
  end

  private

  def group
    @group ||= current_user.founded_groups.invitable.find(params[:group_id])
  end
end
