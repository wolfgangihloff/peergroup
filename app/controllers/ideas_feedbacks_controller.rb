class IdeasFeedbacksController < ApplicationController

  before_filter :authenticate
  before_filter :require_parent_supervision
  require_supervision_step :idea_feedback

  def create
    ideas_feedback = @supervision.build_ideas_feedback(params[:ideas_feedback])
    ideas_feedback.user = current_user
    if ideas_feedback.save
      successful_flash("Feedback submitted")
    else
      error_flash("You must provide feedback")
    end
    redirect_to supervision_path(@supervision)
  end
end

