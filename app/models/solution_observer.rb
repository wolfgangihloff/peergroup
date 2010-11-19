class SolutionObserver < ActiveRecord::Observer
  def after_update(solution)
    supervision = solution.supervision
    supervision.next_step! if supervision.can_move_to_solution_feedback_state?
  end
end

