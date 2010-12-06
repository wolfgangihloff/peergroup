class TopicObserver < ActiveRecord::Observer
  def after_create(topic)
    supervision = topic.supervision.post_topic
  end
end

