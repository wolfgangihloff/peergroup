class SolutionsFeedbacksController < ApplicationController
  self.responder = SupervisionPartResponder

  before_filter :authenticate
  before_filter :fetch_supervision
  require_supervision_step :giving_solutions_feedback, :only => :create

  respond_to :html, :json

  def create
    @solutions_feedback = @supervision.build_solutions_feedback(params[:solutions_feedback])
    @solutions_feedback.user = current_user
    @solutions_feedback.save
    respond_with(@solutions_feedback, :location => @supervision)
  end

  def show
    @solutions_feedback = @supervision.solutions_feedback
    respond_with(@solutions_feedback)
  end

  protected

  def fetch_supervision
    @supervision = Supervision.find(params[:supervision_id])
  end
end

