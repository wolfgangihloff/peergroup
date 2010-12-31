class IdeasFeedback < Feedback
  after_create do |ideas_feedback|
    ideas_feedback.supervision.post_ideas_feedback(ideas_feedback)
  end
end

