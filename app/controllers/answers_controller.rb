class AnswersController < ApplicationController

  before_filter :require_parent_supervision

  def create
    question = @supervision.questions.find(params[:question_id])
    answer = question.build_answer(params[:answer])
    answer.user = current_user
    answer.save!
    successful_flash("Question answered")
    redirect_to supervision_step_path(@supervision)
  end

end

