class IdeasFeedbacksController < ApplicationController
  self.responder = SupervisionPartResponder

  before_filter :authenticate
  before_filter :fetch_supervision
  require_supervision_step :giving_ideas_feedback, :only => :create

  respond_to :html, :json

  def create
    @ideas_feedback = @supervision.build_ideas_feedback(params[:ideas_feedback])
    @ideas_feedback.user = current_user
    @ideas_feedback.save
    respond_with(@ideas_feedback, :location => @supervision)
  end

  def show
    @ideas_feedback = @supervision.ideas_feedback
    respond_with(@ideas_feedback)
  end

  protected

  def fetch_supervision
    @supervision = Supervision.find(params[:supervision_id])
  end
end

