class SupervisionFeedbacksController < ApplicationController
  self.responder = SupervisionPartResponder

  before_filter :authenticate
  before_filter :require_parent_supervision
  require_supervision_step :giving_supervision_feedbacks, :only => :create

  respond_to :html, :json

  def create
    @supervision_feedback = @supervision.supervision_feedbacks.build(params[:supervision_feedback]) do |supervision_feedback|
      supervision_feedback.user = current_user
    end
    @supervision_feedback.save
    respond_with(@supervision_feedback, :location => @supervision)
  end

  def show
    @supervision_feedback = @supervision.supervision_feedbacks.find(params[:id])
    respond_with(@supervision_feedback)
  end
end
