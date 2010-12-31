class SolutionsFeedback < Feedback
  after_create do |solutions_feedback|
    solutions_feedback.supervision.post_solutions_feedback(solutions_feedback)
  end
end

