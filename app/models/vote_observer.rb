class VoteObserver < ActiveRecord::Observer
  def after_create(vote)
    if vote.statement.is_a?(Topic)
      supervision = vote.statement.supervision
      if supervision.state == "topic_vote" && supervision.all_topic_votes?
        supervision.choose_topic
        supervision.next_step!
      end
    end
  end
end

