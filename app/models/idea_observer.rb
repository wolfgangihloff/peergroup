class IdeaObserver < ActiveRecord::Observer
  def after_update(idea)
    supervision = idea.supervision
    supervision.next_step! if supervision.can_move_to_idea_feedback_state?
  end
end

