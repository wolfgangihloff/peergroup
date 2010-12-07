class IdeasFeedback < Feedback
  after_create do |ideas_feedback|
    ideas_feedback.supervision.owner_idea_feedback
  end
end

