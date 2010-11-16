class TopicQuestionsController < ApplicationController

  before_filter :require_parent_supervision

  def new
    if @supervision.problem_owner?(current_user)
      @answer = Answer.new
    else
      @question = Question.new
    end
    render :partial => "questions" if params[:partial]
  end

  def create
    question = @supervision.topic_questions.build(params[:question])
    question.user = current_user
    if question.save
      successful_flash("Question asked")
      redirect_to supervision_step_path(@supervision)
    else
      error_flash("You must provide your question")
      redirect_to new_topic_question_path(:supervision_id => @supervision)
    end
  end

end
