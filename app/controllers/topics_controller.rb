class TopicsController < ApplicationController

  before_filter :authenticate
  before_filter :require_parent_supervision
  require_supervision_step :gathering_topics, :only => :create

  def create
    respond_to do |format|
      @topic = @supervision.topics.build(params[:topic]) do |topic|
        topic.user = current_user
      end
      if @topic.save
        format.js { head :created }
        format.html {
          successful_flash("Topic was submitted successfully")
          redirect_to supervision_path(@supervision)
        }
      else
        format.js { head :bad_request }
        format.html {
          error_flash("You must provide topic")
          redirect_to supervision_path(@supervision)
        }
      end
    end
  end

  def show
    @topic = @supervision.topics.find(params[:id])
    if params[:partial] == "1"
      render :partial => "topic", :layout => false, :locals => { :topic => @topic }
    end
  end
end
