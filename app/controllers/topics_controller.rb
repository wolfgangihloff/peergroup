class TopicsController < ApplicationController
  self.responder = SupervisionPartResponder

  before_filter :authenticate
  before_filter :require_parent_supervision
  require_supervision_step :gathering_topics, :only => :create
  require_supervision_step :gathering_topics, :voting_on_topics, :only => :index

  respond_to :html, :json

  def index
    if params[:partial]
      partial_name = PARTIAL_NAMES[params[:partial]]
      render :partial => partial_name, :layout => false
    else
      @token = SecureRandom.hex
      REDIS.setex("supervision:#{@supervision.id}:users:#{current_user.id}:token:#{@token}", 60, "1")
      REDIS.setex("chat:#{@supervision.chat_room.id}:users:#{current_user.id}:token:#{@token}", 60, "1")
    end
  end

  def create
    @topic = @supervision.topics.build(params[:topic]) do |topic|
      topic.user = current_user
    end
    @topic.save
    respond_with(@topic, :location => @supervision)
  end

  def show
    @topic = @supervision.topics.find(params[:id])
    respond_with(@topic)
  end

  protected

  PARTIAL_NAMES = {
    "topics" => "supervision_topics",
    "topics_votes" => "supervision_topics_votes"
  }
end
