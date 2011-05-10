class IdeasFeedback < Feedback
  include SupervisionRedisPublisher

  after_create do |ideas_feedback|
    ideas_feedback.supervision.post_ideas_feedback
    ideas_feedback.publish_to_redis
  end

  def supervision_publish_attributes
    {:only => [:id, :content, :user_id]}
  end
end
