module GroupsHelper
  def group_name(group, user)
    base = group.name
    user == group.founder ? "#{base}*" : base
  end
end
