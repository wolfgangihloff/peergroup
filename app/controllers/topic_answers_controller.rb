class TopicAnswersController < ApplicationController

  before_filter :require_parent_supervision

  def create
    topic_answer = Answer.new(params[:answer])
    topic_answer.user = current_user
    topic_answer.save!
    successful_flash("Question answered")
    redirect_to supervision_step_path(@supervision)
  end

end

