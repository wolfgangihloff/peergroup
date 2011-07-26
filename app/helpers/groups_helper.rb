module GroupsHelper
  def group_name(group, user)
    base = group.name
    user == group.founder ? "#{base}*" : base
  end

  def link_to_group_supervision(text, group)
    if current_supervision = group.supervisions.current
      if current_supervision.members.include?(current_user)
        link_to text, supervision_path(current_supervision)
      else
        link_to text, supervision_membership_path(current_supervision), :method => :post
      end
    else
      link_to text, new_group_supervision_path(group)
    end
  end
end
