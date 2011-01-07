class SupervisionFeedbacksController < ApplicationController

  before_filter :authenticate
  before_filter :require_parent_supervision
  require_supervision_step :supervision_feedback, :only => :create

  def create
    respond_to do |format|
      @supervision_feedback = @supervision.supervision_feedbacks.build(params[:supervision_feedback]) do |supervision_feedback|
        supervision_feedback.user = current_user
      end
      if @supervision_feedback.save
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
    @supervision_feedback = @supervision.supervision_feedbacks.find(params[:id])
    render(
      :partial => "supervision_feedback",
      :layout => false,
      :locals => { :supervision_feedback => @supervision_feedback }
    ) if params[:partial]
  end
end
