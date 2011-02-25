module GroupsHelper
  def group_name(group, current_user)
    base = group.name
    current_user?(group.founder) ? "#{base}*" : base
  end

  def change_group_membership_link(user, group)
    if user.groups.include?(group)
      membership = user.memberships.find_by_group_id(group.id)
      link_to t(".links.leave", :default => "leave"), group_membership_path(group, membership), :method => :delete
    else
      link_to t(".links.join", :default => "join"), group_memberships_path(group), :method => :post
    end
  end
end

