class SupervisionFeedback < Feedback
  after_create do |supervision_feedback|
    supervision_feedback.supervision.post_supervision_feedback(supervision_feedback)
  end
end
