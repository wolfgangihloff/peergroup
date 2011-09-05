class Founder::RequestsController < ApplicationController
  before_filter :authenticate

  def update
    membership.accept!
    redirect_to edit_founder_group_path(group), :notice => "User is now part of group"
  end

  def destroy
    membership.destroy
    redirect_to edit_founder_group_path(group), :notice => "User membership request rejected"
  end

  private

  def membership
    @membership ||= group.requested_memberships.find(params[:id])
  end

  def group
    @group ||= current_user.founded_groups.find(params[:group_id])
  end
end
