class TopicsController < ApplicationController
  self.responder = SupervisionPartResponder

  before_filter :authenticate
  before_filter :require_supervision_membership, :only => [:index, :create]
  require_supervision_state :gathering_topics, :only => :create
  require_supervision_state :gathering_topics, :voting_on_topics, :only => :index

  respond_to :html, :json

  def index
    render :partial => "supervision_topics_votes", :layout => false, :locals => {:supervision => supervision}
  end

  def create
    @topic = supervision.topics.build(params[:topic]) do |topic|
      topic.user = current_user
    end
    @topic.save
    respond_with(@topic, :location => supervision)
  end

  def show
    @topic = supervision.topics.find(params[:id])
    respond_with(@topic)
  end

  protected

  def supervision
    @supervision ||= Supervision.find(params[:supervision_id])
  end

  def require_supervision_membership
    unless supervision.members.exists?(current_user)
      redirect_to new_supervision_membership_path(supervision)
    end
  end
end
