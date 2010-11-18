class IdeasFeedbacksController < ApplicationController
  before_filter :require_parent_supervision

  def create
    ideas_feedback = IdeasFeedback.new(params[:ideas_feedback])
    ideas_feedback.supervision = @supervision
    ideas_feedback.user = current_user
    ideas_feedback.save!
    successful_flash("Feedback submitted")
    redirect_to supervision_step_path(@supervision)
  end
end

