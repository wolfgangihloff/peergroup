class AnswersController < ApplicationController

  before_filter :authenticate
  before_filter :require_parent_supervision
  require_supervision_step :topic_question

  def create
    question = @supervision.questions.find(params[:question_id])
    answer = question.build_answer(params[:answer])
    answer.user = current_user
    if answer.save
      successful_flash("Question answered")
    else
      error_flash("You must provide answer")
    end
    redirect_to supervision_path(@supervision)
  end

end

