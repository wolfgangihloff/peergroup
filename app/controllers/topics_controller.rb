class TopicsController < ApplicationController

  before_filter :require_parent_supervision
  before_filter :redirect_to_correct_supervision_step

  def new
    @topic = @supervision.topics.build
  end

  def index
    @topics = @supervision.topics
  end

  def create
    topic = @supervision.topics.build(params[:topic])
    topic.user = current_user
    topic.save!
    successful_flash "Topic was submitted successfully."
    redirect_to supervision_step_path(@supervision)
  end
end
