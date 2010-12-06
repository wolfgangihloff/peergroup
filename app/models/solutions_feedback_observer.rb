class SolutionsFeedbackObserver < ActiveRecord::Observer
  def after_create(solutions_feedback)
    solutions_feedback.supervision.owner_solution_feedback
  end
end

