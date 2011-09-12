class VotesController < ApplicationController
  self.responder = SupervisionPartResponder

  before_filter :authenticate_user!
  before_filter :require_supervision_membership
  require_supervision_state :asking_questions, :providing_ideas, :providing_solutions, :only => :create

  respond_to :html, :json

  def create
    @vote = supervision.next_step_votes.build do |vote|
      vote.user = current_user
    end
    @vote.save
    respond_with(@vote, :location => supervision)
  end

  private

  def supervision
    @supervision ||= Supervision.find(params[:supervision_id])
  end

  def require_supervision_membership
    unless supervision.members.exists?(current_user)
      redirect_to new_supervision_membership_path(supervision)
    end
  end
end
