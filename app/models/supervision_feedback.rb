class SupervisionFeedback < Feedback
  include SupervisionRedisPublisher

  after_create do |supervision_feedback|
    supervision_feedback.supervision.post_supervision_feedback
    supervision_feedback.publish_to_redis
  end

  def supervision_publish_attributes
    {:only => [:id, :content, :user_id]}
  end
end
