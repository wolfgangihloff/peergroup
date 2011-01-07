class QuestionsController < ApplicationController

  before_filter :authenticate
  before_filter :require_parent_supervision
  require_supervision_step :topic_question, :only => :create

  def create
    respond_to do |format|
      @question = @supervision.topic_questions.build(params[:question]) do |question|
        question.user = current_user
      end
      if @question.save
        format.js { head :created }
        format.html {
          successful_flash("Question asked")
          redirect_to supervision_path(@supervision)
        }
      else
        format.js { head :bad_request }
        format.html {
          error_flash("You must provide your question")
          redirect_to supervision_path(@supervision)
        }
      end
    end
  end

  def show
    @question = @supervision.questions.find(params[:id])
    render(
      :partial => "question",
      :layout => false,
      :locals => { :question => @question }
    ) if params[:partial]
  end

end
