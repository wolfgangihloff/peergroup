class SolutionsFeedbacksController < ApplicationController

  before_filter :require_parent_supervision

  def create
    solutions_feedback = SolutionsFeedback.new(params[:solutions_feedback])
    solutions_feedback.supervision = @supervision
    solutions_feedback.user = current_user
    solutions_feedback.save!
    successful_flash("Feedback submitted")
    redirect_to supervision_step_path(@supervision)
  end
end

