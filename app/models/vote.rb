class Vote < ActiveRecord::Base
  belongs_to :user
  belongs_to :statement, :polymorphic => true, :touch => true

  validates_presence_of :user
  validates_presence_of :statement

  attr_accessible

  after_create do |vote|
    case vote.statement
    when Topic
      vote.statement.supervision.post_topic_vote
    when Supervision
      vote.statement.post_vote_for_next_step
    end
  end
end

