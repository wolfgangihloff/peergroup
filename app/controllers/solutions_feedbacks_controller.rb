class SolutionsFeedbacksController < ApplicationController
  self.responder = SupervisionPartResponder

  before_filter :authenticate
  before_filter :require_supervision_membership
  require_supervision_state :giving_solutions_feedback, :only => :create

  respond_to :html, :json

  def create
    @solutions_feedback = supervision.build_solutions_feedback(params[:solutions_feedback])
    @solutions_feedback.user = current_user
    @solutions_feedback.save
    respond_with(@solutions_feedback, :location => supervision)
  end

  def show
    @solutions_feedback = supervision.solutions_feedback
    respond_with(@solutions_feedback)
  end

  protected

  def supervision
    @supervision ||= Supervision.find(params[:supervision_id])
  end

  def require_supervision_membership
    unless supervision.members.exists?(current_user)
      redirect_to new_supervision_membership_path(supervision)
    end
  end
end
