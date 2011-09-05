class MembershipsController < ApplicationController
  before_filter :authenticate

  def create
    @group = Group.open.find(params[:group_id])
    @group.add_member!(current_user)
    successful_flash("You are now a member of the group %{group_name}", :group_name => @group.name)
    redirect_to @group
  end

  def destroy
    if group.founded_by?(current_user)
      error_flash("Group founder cannot leave group")
    else
      current_user.groups.delete(group)
      successful_flash("You are no longer the member of the group %{group_name}", :group_name => group.name)
    end
    redirect_to groups_path
  end

  private

  def group
    @group ||= Group.find(params[:group_id])
  end
end
