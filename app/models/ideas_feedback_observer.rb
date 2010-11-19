class IdeasFeedbackObserver < ActiveRecord::Observer
  def after_create(ideas_feedback)
    supervision = ideas_feedback.supervision
    supervision.next_step! if supervision.state == "idea_feedback"
  end
end

