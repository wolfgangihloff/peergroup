module GroupsHelper
  def group_name(group, current_user)
    base = group.name
    group.founder == current_user ? "#{base}*" : base
  end
end

