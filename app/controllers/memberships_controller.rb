class MembershipsController < ApplicationController

  before_filter :require_parent_group

  def create
    @group.add_member!(current_user)
    flash[:notice] = "You are now the member of the group #{@group.name}"
    redirect_to @group
  end

  def destroy
    @group.memberships.find(params[:id]).destroy
    flash[:notice] = "You are no longer the member of the group #{@group.name}"
    redirect_to groups_path
  end
end
