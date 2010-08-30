# By using the symbol ':user', we get Factory Girl to simulate the User model.
Factory.define :user do |user|
  user.sequence(:name)       {|i| "User name #{i}"}
  user.sequence(:email)      {|i| "mhartl#{i}@example.com"}
  user.password              "foobar"
  user.password_confirmation "foobar"
end

Factory.define :micropost do |micropost|
  micropost.content "Foo bar"
  micropost.association :user
end

Factory.define :chat_update do |chat_update|
  chat_update.user_id { Factory(:user).id }
  chat_update.login {|cu| cu.user.name }
end
