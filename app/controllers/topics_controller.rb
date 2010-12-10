class TopicsController < ApplicationController

  before_filter :authenticate
  before_filter :require_parent_supervision
  require_supervision_step :topic

  def create
    topic = @supervision.topics.build(params[:topic]) do |topic|
      topic.user = current_user
    end
    if topic.save
      successful_flash("Topic was submitted successfully")
    else
      error_flash("You must provide topic")
    end
    redirect_to supervision_path(@supervision)
  end
end
