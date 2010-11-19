class SolutionsFeedbackObserver < ActiveRecord::Observer
  def after_create(solutions_feedback)
    supervision = solutions_feedback.supervision
    supervision.next_step! if supervision.state == "solution_feedback"
  end
end

