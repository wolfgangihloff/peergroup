class VoteObserver < ActiveRecord::Observer
  def after_create(vote)
    case vote.statement
    when Topic
      vote.statement.supervision.post_topic_vote
    when Supervision
      vote.statement.post_vote_for_next_step
    end
  end
end

