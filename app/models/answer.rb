class Answer < ActiveRecord::Base
  belongs_to :user
  belongs_to :question

  validates_presence_of :user
  validates_presence_of :question
  validates_presence_of :content

  attr_accessible :content

  after_create do |answer|
    answer.supervision.post_vote_for_next_step(answer)
  end

  delegate :supervision, :to => :question
end

