class TopicObserver < ActiveRecord::Observer
  def after_create(topic)
    supervision = topic.supervision
    if supervision.state == "topic" && supervision.all_topics?
      supervision.next_step!
    end
  end
end

