class TopicsController < ApplicationController
  self.responder = SupervisionPartResponder

  before_filter :authenticate
  before_filter :fetch_supervision, :only => [:index, :create]
  require_supervision_state :gathering_topics, :only => :create
  require_supervision_state :gathering_topics, :voting_on_topics, :only => :index

  respond_to :html, :json

  def index
    if params[:partial]
      partial_name = PARTIAL_NAMES[params[:partial]]
      render :partial => partial_name, :layout => false, :locals => { :supervision => @supervision }
    else
      @chat_room = @supervision.chat_room
      @chat_messages = @chat_room.chat_messages.recent

      @token = @chat_room.set_redis_access_token_for_user(current_user)
      REDIS.setex("supervision:#{@supervision.id}:users:#{current_user.id}:token:#{@token}", 60, "1")
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
    @topic = Topic.find(params[:id])
    @supervision = @topic.supervision
    respond_with(@topic)
  end

  protected

  def fetch_supervision
    @supervision = Supervision.find(params[:supervision_id])
  end

  PARTIAL_NAMES = {
    "topics" => "supervision_topics",
    "topics_votes" => "supervision_topics_votes"
  }
end
