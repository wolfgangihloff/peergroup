class VoteObserver < ActiveRecord::Observer
  def after_create(vote)
    case vote.statement
    when Topic
      supervision = vote.statement.supervision
      if supervision.state == "topic_vote" && supervision.all_topic_votes?
        supervision.choose_topic
        supervision.next_step!
      end
    when Supervision
      supervision = vote.statement
      supervision.next_step! if supervision.can_move_to_idea_state? || supervision.can_move_to_idea_feedback_state?
    end
  end
end

