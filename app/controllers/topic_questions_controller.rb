class TopicQuestionsController < ApplicationController

  before_filter :require_parent_supervision

  def new
    @question = Question.new
  end

  def create
    question = @supervision.topic_questions.build(params[:question])
    question.user = current_user
    question.save!
    successful_flash("Question asked")
    redirect_to supervision_step_path(@supervision)
  end

end
