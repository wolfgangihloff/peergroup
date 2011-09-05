class Founder::InvitationsController < ApplicationController
  before_filter :authenticate

  def new
    @membership = group.memberships.build(params[:membership])
  end

  def create
    @membership = group.memberships.build(params[:membership])
    if @membership.save && @membership.invite!
      redirect_to edit_founder_group_path(group), :notice => "User invited"
    else
      render :new
    end
  end

  private

  def group
    @group ||= current_user.founded_groups.closed.find(params[:group_id])
  end
end
