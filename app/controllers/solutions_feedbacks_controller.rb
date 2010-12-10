class SolutionsFeedbacksController < ApplicationController

  before_filter :authenticate
  before_filter :require_parent_supervision
  require_supervision_step :solution_feedback

  def create
    solutions_feedback = @supervision.build_solutions_feedback(params[:solutions_feedback])
    solutions_feedback.user = current_user
    if solutions_feedback.save
      successful_flash("Feedback submitted")
    else
      error_flash("You must provide feedback")
    end
    redirect_to supervision_path(@supervision)
  end
end

