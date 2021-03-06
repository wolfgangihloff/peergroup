class Founder::MembershipsController < ApplicationController
  before_filter :authenticate_user!

  def destroy
    @membership = group.memberships.find_by_user_id(params[:id])
    @membership.destroy
    redirect_to edit_founder_group_path(@group), :notice => "User removed from group"
  end

  private

  def group
    @group ||= current_user.founded_groups.find(params[:group_id])
  end
end
