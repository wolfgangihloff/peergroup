Given /^the group exists with user: "([^"]*)", name: "([^"]*)" and chat message: "([^"]*)"$/ do |user_name, group_name, chat_message|
  founder = Factory(:user, :name => user_name)
  group = Factory(:group, :name => group_name, :founder => founder)
  Factory(:chat_update, :chat_room => group.chat_room, :message => chat_message)
end

When /^the user "([^"]*)" is in the chat room of group "([^"]*)"$/ do |user_name, group_name|
  user = User.find_by_name(user_name) || Factory(:user, :name => user_name)
  group = Group.find_by_name(group_name)
  p Factory(:chat_user, :user => user, :chat_room => group.chat_room)
end
