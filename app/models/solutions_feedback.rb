class SolutionsFeedback < Feedback
  include SupervisionRedisPublisher

  after_create do |solutions_feedback|
    solutions_feedback.supervision.post_solutions_feedback
    solutions_feedback.publish_to_redis
  end

  def supervision_publish_attributes
    {:only => [:id, :content, :user_id]}
  end
end
