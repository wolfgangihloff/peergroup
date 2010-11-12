class TopicVoteObserver < ActiveRecord::Observer
  def after_create(vote)
    supervision = vote.supervision
    if supervision.state == "topic_vote" && vote.statement.is_a?(Topic) && supervision.all_topics?
      supervision.next_step!
    end
  end
end

