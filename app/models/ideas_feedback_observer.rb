class IdeasFeedbackObserver < ActiveRecord::Observer
  def after_create(ideas_feedback)
    ideas_feedback.supervision.owner_idea_feedback
  end
end

