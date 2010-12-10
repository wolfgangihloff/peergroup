class QuestionsController < ApplicationController

  before_filter :authenticate
  before_filter :require_parent_supervision
  require_supervision_step :topic_question

  def create
    question = @supervision.topic_questions.build(params[:question]) do |question|
      question.user = current_user
    end
    if question.save
      successful_flash("Question asked")
    else
      error_flash("You must provide your question")
    end
    redirect_to supervision_path(@supervision)
  end

end
