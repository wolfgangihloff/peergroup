Given /^the session for the group "([^"]*)" is started by "([^"]*)"$/ do |group_name, founder|
  group = Group.find_by_name(group_name)
  group.supervisions.create!
end

