Given /^the group exists with user: "([^"]*)", name: "([^"]*)" and chat message: "([^"]*)"$/ do |user_name, group_name, chat_message|
  founder = Factory(:user, :name => user_name)
  group = Factory(:group, :name => group_name, :founder => founder)
  Factory(:chat_update, :chat_room => group.chat_room, :message => chat_message)
end

