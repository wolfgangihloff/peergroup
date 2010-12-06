class AnswerObserver < ActiveRecord::Observer
  def after_create(answer)
    answer.supervision.post_vote_for_next_step
  end
end

