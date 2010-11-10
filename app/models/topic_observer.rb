class TopicObserver < ActiveRecord::Observer
  def after_create(topic)
    supervision = topic.supervision
    if supervision.all_topics?
      supervision.state = "topic_vote"
      supervision.save!
    end
  end
end

