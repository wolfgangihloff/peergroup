class IdeasFeedbacksController < ApplicationController
  self.responder = SupervisionPartResponder

  before_filter :authenticate
  before_filter :require_supervision_membership
  require_supervision_state :giving_ideas_feedback, :only => :create

  respond_to :html, :json

  def create
    @ideas_feedback = supervision.build_ideas_feedback(params[:ideas_feedback])
    @ideas_feedback.user = current_user
    @ideas_feedback.save
    respond_with(@ideas_feedback, :location => supervision)
  end

  def show
    @ideas_feedback = supervision.ideas_feedback
    respond_with(@ideas_feedback)
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
