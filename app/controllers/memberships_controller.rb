class MembershipsController < ApplicationController

  before_filter :require_parent_group

  def create
    @group.add_member!(current_user)
    successful_flash("You are now the member of the group %{group_name}", :group_name => @group.name)
    redirect_to @group
  end

  def destroy
    @group.memberships.find(params[:id]).destroy
    successful_flash("You are no longer the member of the group %{group_name}", :group_name => @group.name)
    redirect_to groups_path
  end
end
