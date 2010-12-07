class SupervisionFeedback < Feedback
  after_create do |supervision_feedback|
    supervision_feedback.supervision.general_feedback
  end
end
