class AnswersController < ApplicationController

  before_filter :authenticate
  before_filter :require_parent_supervision
  require_supervision_step :asking_questions, :only => :create

  def create
    respond_to do |format|
      @question = @supervision.questions.find(params[:question_id])
      @answer = @question.build_answer(params[:answer])
      @answer.user = current_user
      if @answer.save
        format.js { head :created }
        format.html {
          successful_flash("Question answered")
          redirect_to supervision_path(@supervision)
        }
      else
        format.js { head :bad_request }
        format.html {
          error_flash("You must provide answer")
          redirect_to supervision_path(@supervision)
        }
      end
    end
  end

end

