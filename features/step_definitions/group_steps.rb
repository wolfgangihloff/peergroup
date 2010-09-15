Given /^the group exists with user: "([^"]*)", name: "([^"]*)" and chat message: "([^"]*)"$/ do |user_name, group_name, chat_message|
  founder = Factory(:user, :name => user_name)
  group = Factory(:group, :name => group_name, :founder => founder)
  Factory(:chat_update, :chat_room => group.chat_room, :message => chat_message, :state => "commited")
end

When /^the user "([^"]*)" is the member of the group "([^"]*)"$/ do |user_name, group_name|
  user = User.find_by_name(user_name) || Factory(:user)
  Group.find_by_name(group_name).add_member!(user)
end

When /^the user "([^"]*)" (?:is in|enters) the chat room of group "([^"]*)"$/ do |user_name, group_name|
  user = User.find_by_name(user_name) || Factory(:user, :name => user_name)
  group = Group.find_by_name(group_name)
  Factory(:chat_user, :user => user, :chat_room => group.chat_room)
end

Then /^the user "([^"]*)" should (not )?be the member of the group "([^"]*)"$/ do |user_name, denial, group_name|
  user = User.find_by_name(user_name)
  group = user.groups.find_by_name(group_name)
  if denial
    group.should be_nil
  else
    group.should_not be_nil
  end
end

Then /^user "([^"]*)" should be the (.+) of the chat room of the group "([^"]*)"$/ do |user_name, role, group_name|
  user = User.find_by_name(user_name)
  group = Group.find_by_name(group_name)
  role.gsub!(' ', '_')
  group.chat_room.send(role).should == user
end

When /^the "([^"]*)" group chat current rule changes to "([^"]*)"$/ do |group_name, rule_name|
  chat_room = Group.find_by_name(group_name).chat_room
  chat_room.current_rule = Rule.find_by_name(rule_name)
  chat_room.save!
end

