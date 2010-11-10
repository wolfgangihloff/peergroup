class TopicsController < ApplicationController

  before_filter :require_parent_supervision


  def new
    @topic = @supervision.topics.build
  end

  def index
    @topics = @supervision.topics
  end

  def create
    topic = @supervision.topics.build(params[:topic])
    topic.author = current_user
    topic.save!
    successful_flash "Topic was submitted successfully."
    redirect_to topics_path(:supervision_id => @supervision.id)
  end

  protected

  def require_parent_supervision
    @supervision = Supervision.find(params[:supervision_id])
  end

end
