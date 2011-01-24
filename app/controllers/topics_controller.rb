class TopicsController < ApplicationController

  before_filter :authenticate
  before_filter :require_parent_supervision
  require_supervision_step :gathering_topics, :only => :create
  require_supervision_step :gathering_topics, :voting_on_topics, :only => :index

  def index
    if params[:partial]
      partial_name = PARTIAL_NAMES[params[:partial]]
      render :partial => partial_name, :layout => false
    else
      @token = SecureRandom.hex
      REDIS.setex("supervision:#{@supervision.id}:users:#{current_user.id}:token:#{@token}", 60, "1")
    end
  end

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

  protected

  PARTIAL_NAMES = {
    "topics" => "supervision_topics",
    "topics_votes" => "supervision_topics_votes"
  }
end
