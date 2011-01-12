class SolutionsFeedbacksController < ApplicationController

  before_filter :authenticate
  before_filter :require_parent_supervision
  require_supervision_step :giving_solutions_feedback, :only => :create

  def create
    respond_to do |format|
      @solutions_feedback = @supervision.build_solutions_feedback(params[:solutions_feedback])
      @solutions_feedback.user = current_user
      if @solutions_feedback.save
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
    @solutions_feedback = @supervision.solutions_feedback
    render(
      :partial => "solutions_feedback",
      :layout => false,
      :locals => { :solutions_feedback => @solutions_feedback }
    ) if params[:partial]
  end
end

