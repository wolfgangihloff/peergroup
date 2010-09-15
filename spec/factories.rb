# By using the symbol ':user', we get Factory Girl to simulate the User model.
Factory.define :user do |user|
  user.sequence(:name)       {|i| "User name #{i}"}
  user.sequence(:email)      {|i| "mhartl#{i}@example.com"}
  user.password              "foobar"
  user.password_confirmation "foobar"
end

Factory.define :chat_user do |chat_user|
  chat_user.user { Factory(:user) }
  chat_user.chat_room { Factory(:chat_room) }
end


Factory.define :micropost do |micropost|
  micropost.content "Foo bar"
  micropost.association :user
end

Factory.define :chat_update do |chat_update|
  chat_update.user_id { Factory(:user).id }
  chat_update.chat_room_id { Factory(:chat_room).id }
  chat_update.login {|cu| cu.user.name }
  chat_update.sequence(:message) {|i| "Hi there! I said it #{i} times."}
end

Factory.define(:funny_chat_update, :parent => :chat_update) do |funny_chat_update|
  funny_chat_update.state "commited"
  funny_chat_update.chat_room_id do
    group = Group.find_by_name("Funny") || Factory(:group, :name => "Funny")
    group.chat_room.id
  end
end

Factory.define :group do |group|
  group.sequence(:name) {|i| "Group #{i}"}
  group.description "Very nice group"
  group.founder { Factory(:user) }
end

Factory.define(:freds_group, :parent => :group) do |freds_group|
  freds_group.founder { Factory(:user, :name => "Fred") }
end

Factory.define(:chat_room) do |chat_room|
  chat_room.group { Factory(:group) }
end

