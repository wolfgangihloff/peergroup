class MembershipsController < ApplicationController
  before_filter :require_parent_group

  def create
    @group.add_member!(current_user)
    successful_flash("You are now a member of the group %{group_name}", :group_name => @group.name)
    redirect_to @group
  end

  def destroy
    current_user.groups.delete(@group)
    successful_flash("You are no longer the member of the group %{group_name}", :group_name => @group.name)
    redirect_to groups_path
  end

  def accept
    @membership = current_user.pending_memberships.find_by_group_id(@group)
    @membership.accept!
    redirect_to groups_path, :notice => "Accepted!"
  end

  def reject
    @membership = current_user.pending_memberships.find_by_group_id(@group)
    @membership.destroy
    redirect_to groups_path, :notice => "Rejected!"
  end
end
