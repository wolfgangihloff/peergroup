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
      supervision.next_step! if %w{idea idea_feedback solution_feedback}.any? do |step|
        supervision.send("can_move_to_#{step}_state?")
      end
    end
  end
end

