# By using the symbol ':user', we get Factory Girl to simulate the User model.
Factory.define :user do |user|
  user.sequence(:name)       {|i| "User name #{i}"}
  user.sequence(:email)      {|i| "mhartl#{i}@example.com"}
  user.password              "foobar"
  user.password_confirmation "foobar"
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

Factory.define(:supervision) do |supervision|
  supervision.group { Factory(:group) }
end

Factory.define(:topic) do |topic|
  topic.supervision { Factory(:supervision) }
  topic.user {|t| t.supervision.group.founder }
end

Factory.define(:vote) do |vote|
  vote.statement { Factory(:topic) }
  vote.user {|t| t.statement.user }
end

Factory.define(:question) do |question|
  question.supervision { Factory(:supervision) }
  question.user {|q| q.supervision.group.members.first }
  question.content "Why?"
end

Factory.define(:idea) do |question|
  question.supervision { Factory(:supervision) }
  question.user {|q| q.supervision.group.members.first }
  question.content "Less talk, more action."
end

Factory.define(:ideas_feedback) do |question|
  question.supervision { Factory(:supervision) }
  question.user {|q| q.supervision.group.founder }
  question.content "Thanks for the ideas!"
end

Factory.define(:answer) do |answer|
  answer.question { Factory(:question) }
  answer.user {|q| q.question.supervision.group.members.first }
  answer.content "Just because."
end

