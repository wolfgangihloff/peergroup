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

Factory.define :freds_group, :parent => :group do |freds_group|
  freds_group.founder { Factory(:user, :name => "Fred") }
end

Factory.define :chat_room do |chat_room|
  chat_room.group { Factory(:group) }
end

Factory.define :chat_message do |chat_message|
  chat_message.user { Factory(:user) }
  chat_message.chat_room { Factory(:chat_room) }
  chat_message.content "Hi there"
end

Factory.define :supervision do |supervision|
  supervision.group { Factory(:group) }
end

Factory.define :topic do |topic|
  topic.supervision { Factory(:supervision) }
  topic.user { Factory(:user) }
end

Factory.define :vote do |vote|
  vote.statement { Factory(:topic) }
  vote.user { Factory(:user) }
end

Factory.define :supervision_vote, :parent => :vote do |vote|
  vote.statement { Factory(:supervision) }
  vote.user { Factory(:user) }
end

Factory.define :question do |question|
  question.supervision { Factory(:supervision) }
  question.user { Factory(:user) }
  question.content "Why?"
end

Factory.define :answer do |answer|
  answer.question { Factory(:question) }
  answer.user { Factory(:user) }
  answer.content "Just because."
end

Factory.define :idea do |idea|
  idea.supervision { Factory(:supervision) }
  idea.user { Factory(:user) }
  idea.content "Less talk, more action."
end

Factory.define :ideas_feedback do |feedback|
  feedback.supervision { Factory(:supervision) }
  feedback.user { Factory(:user) }
  feedback.content "Thanks for the ideas!"
end

Factory.define :solution do |solution|
  solution.supervision { Factory(:supervision) }
  solution.user { Factory(:user) }
  solution.content "Solution"
end

Factory.define :solutions_feedback do |feedback|
  feedback.supervision { Factory(:supervision) }
  feedback.user { Factory(:user) }
  feedback.content "Thanks for the solutions!"
end

Factory.define :supervision_feedback do |feedback|
  feedback.supervision { Factory(:supervision) }
  feedback.user { Factory(:user) }
  feedback.content "Feedback"
end

