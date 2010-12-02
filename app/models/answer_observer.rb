class AnswerObserver < ActiveRecord::Observer
  def after_create(answer)
    supervision = answer.supervision
    supervision.next_step! if supervision.can_move_to_idea_state?
  end
end

