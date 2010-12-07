class SolutionsFeedback < Feedback
  after_create do |solutions_feedback|
    solutions_feedback.supervision.owner_solution_feedback
  end
end

