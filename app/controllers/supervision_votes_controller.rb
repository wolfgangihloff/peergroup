class SupervisionVotesController < ApplicationController

  before_filter :require_parent_supervision
  before_filter :require_questions_step

  def create
    @supervision.next_step_votes.create!(:user => current_user)
    redirect_to supervision_step_path(@supervision)
  end

  protected

  def require_questions_step
    unless @supervision.state == "topic_question"
      redirect_to supervision_step_path(@supervision)
      return false
    end
  end
end

