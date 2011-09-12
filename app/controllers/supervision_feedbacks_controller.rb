class SupervisionFeedbacksController < ApplicationController
  self.responder = SupervisionPartResponder

  before_filter :authenticate_user!
  before_filter :fetch_supervision_feedback, :only => :show
  before_filter :fetch_supervision, :only => :create
  before_filter :require_supervision_membership
  require_supervision_state :giving_supervision_feedbacks, :only => :create

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

  protected

  def fetch_supervision_feedback
    @supervision_feedback = SupervisionFeedback.find(params[:id])
    @supervision = @supervision_feedback.supervision
  end

  def fetch_supervision
    @supervision = Supervision.find(params[:supervision_id])
  end

  def require_supervision_membership
    unless @supervision.members.exists?(current_user)
      redirect_to new_supervision_membership_path(@supervision)
    end
  end
end
