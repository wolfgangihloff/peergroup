FactoryGirl.define do
  factory :user do
    sequence(:name)       { |i| "User name #{i}" }
    sequence(:email)      { |i| "mhartl#{i}@example.com" }
    password              "foobar"
    password_confirmation { password }
  end

  factory :group do
    sequence(:name) { |i| "Group #{i}"}
    description "Very nice group"
    association :founder, :factory => :user
  end

  factory :freds_group, :parent => :group do
    association :founder, :factory => :user, :name => "Fred"
  end

  factory :chat_room do
    group
  end

  factory :chat_message do
    user
    chat_room
    content "Hi there"
  end

  factory :supervision do
    group
  end

  factory :topic do
    supervision
    user
  end

  factory :vote do
    association :statement, :factory => :topic
    user
  end

  factory :supervision_vote, :parent => :vote do
    association :statement, :factory => :supervision
  end

  factory :question do
    supervision
    user
    content "Why?"
  end

  factory :answer do
    question
    user
    content "Just because."
  end

  factory :idea do
    supervision
    user
    content "Less talk, more action."
  end

  factory :ideas_feedback do
    supervision
    user
    content "Thanks for the ideas!"
  end

  factory :solution do
    supervision
    user
    content "Solution"
  end

  factory :solutions_feedback do
    supervision
    user
    content "Thanks for the solutions!"
  end

  factory :supervision_feedback do
    supervision
    user
    content "Feedback"
  end

  factory :membership do
    group
    sequence(:email) { |i| "john#{i}@doe.com"}
  end
end
