class VotesController < ApplicationController

  before_filter :require_parent_supervision
  before_filter :require_voteable_step

  def create
    @supervision.next_step_votes.create!(:user => current_user)
    redirect_to supervision_step_path(@supervision)
  end

  protected

  def require_voteable_step
    unless %w{topic_question idea solution}.include?(@supervision.state)
      redirect_to supervision_step_path(@supervision)
      return false
    end
  end
end

