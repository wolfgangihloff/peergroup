class RequestsController < ApplicationController
  before_filter :authenticate

  def create
    @membership = group.memberships.build(:email => current_user.email)
    if @membership.save && @membership.request!
      flash[:notice] = "Group membership requested"
    else
      flash[:alert] = "Cannot request membership"
    end
    redirect_to groups_path
  end

  private

  def group
    @group ||= Group.invitable.find(params[:group_id])
  end
end
