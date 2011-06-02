class InvitationsController < ApplicationController
  before_filter :authenticate

  def update
    membership.accept!
    redirect_to groups_path, :notice => "Accepted!"
  end

  def destroy
    membership.destroy
    redirect_to groups_path, :notice => "Rejected!"
  end

  private

  def membership
    @membership ||= current_user.invited_memberships.find_by_group_id(group)
  end

  def group
    @group ||= Group.find(params[:group_id])
  end
end
