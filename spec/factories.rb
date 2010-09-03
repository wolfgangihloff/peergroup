# By using the symbol ':user', we get Factory Girl to simulate the User model.
Factory.define :user do |user|
  user.sequence(:name)       {|i| "User name #{i}"}
  user.sequence(:email)      {|i| "mhartl#{i}@example.com"}
  user.password              "foobar"
  user.password_confirmation "foobar"
end

Factory.define :chatting_user, :parent => :user do |chatting_user|
  chatting_user.seen_on_chat { Time.now }
end

Factory.define :micropost do |micropost|
  micropost.content "Foo bar"
  micropost.association :user
end

Factory.define :chat_update do |chat_update|
  chat_update.user_id { Factory(:user).id }
  chat_update.login {|cu| cu.user.name }
  chat_update.sequence(:message) {|i| "Hi there! I said it #{i} times."}
end

Factory.define :group do |group|
  group.sequence(:name) {|i| "Group #{i}"}
  group.description "Very nice group"
  group.founder { Factory(:user) }
  group.members {|g| [g.founder]}
end

Factory.define(:freds_group, :parent => :group) do |freds_group|
  freds_group.founder { Factory(:user, :name => "Fred") }
end

