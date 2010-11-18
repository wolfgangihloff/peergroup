class IdeasFeedbackObserver < ActiveRecord::Observer
  def after_create(ideas_feedback)
    ideas_feedback.supervision.next_step!
  end
end

