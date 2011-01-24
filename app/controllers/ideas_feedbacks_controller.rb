class IdeasFeedbacksController < ApplicationController

  before_filter :authenticate
  before_filter :require_parent_supervision
  require_supervision_step :giving_ideas_feedback, :only => :create

  def create
    respond_to do |format|
      @ideas_feedback = @supervision.build_ideas_feedback(params[:ideas_feedback])
      @ideas_feedback.user = current_user
      if @ideas_feedback.save
        format.js { head :created }
        format.html {
          successful_flash("Feedback submitted")
          redirect_to supervision_path(@supervision)
        }
      else
        format.js { head :bad_request }
        format.html {
          error_flash("You must provide feedback")
          redirect_to supervision_path(@supervision)
        }
      end
    end
  end

  def show
    @ideas_feedback = @supervision.ideas_feedback
    render(
      :partial => "ideas_feedback",
      :layout => false,
      :locals => { :ideas_feedback => @ideas_feedback }
    ) if params[:partial]
  end
end

