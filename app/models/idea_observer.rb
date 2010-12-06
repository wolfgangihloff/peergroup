class IdeaObserver < ActiveRecord::Observer
  def after_update(idea)
    idea.supervision.post_vote_for_next_step
  end
end

