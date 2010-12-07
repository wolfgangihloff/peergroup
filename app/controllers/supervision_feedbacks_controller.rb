class SupervisionFeedbacksController < ApplicationController

  before_filter :require_parent_supervision
  require_supervision_step :supervision_feedback

  def index

  end

  def create
    supervision_feedback = @supervision.supervision_feedbacks.build(params[:supervision_feedback]) do |sf|
      sf.user = current_user
    end
    supervision_feedback.save!
    successful_flash("Feedback submitted")
    redirect_to supervision_step_path(@supervision)
  end
end
