class SupervisionFeedbacksController < ApplicationController

  before_filter :authenticate
  before_filter :require_parent_supervision
  require_supervision_step :supervision_feedback

  def create
    supervision_feedback = @supervision.supervision_feedbacks.build(params[:supervision_feedback]) do |supervision_feedback|
      supervision_feedback.user = current_user
    end
    if supervision_feedback.save
      successful_flash("Feedback submitted")
    else
      error_flash("You must provide feedback")
    end
    redirect_to supervision_path(@supervision)
  end
end
