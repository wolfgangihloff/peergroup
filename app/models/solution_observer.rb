class SolutionObserver < ActiveRecord::Observer
  def after_update(solution)
    solution.supervision.post_vote_for_next_step
  end
end

