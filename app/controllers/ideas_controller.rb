class IdeasController < ApplicationController
  self.responder = SupervisionPartResponder

  before_filter :authenticate
  before_filter :fetch_idea, :only => [:update, :show]
  before_filter :fetch_supervision, :only => :create
  require_supervision_state :providing_ideas, :only => [:create, :update]

  respond_to :html, :json

  def create
    @idea = @supervision.ideas.build(params[:idea]) do |idea|
      idea.user = current_user
    end
    @idea.save
    respond_with(@idea, :location => @supervision)
  end

  def update
    @idea.update_attributes(params[:idea])
    respond_with(@idea, :location => @supervision)
  end

  def show
    respond_with(@idea)
  end

  protected

  def fetch_idea
    @idea = Idea.find(params[:id])
    @supervision = @idea.supervision
  end

  def fetch_supervision
    @supervision = Supervision.find(params[:supervision_id])
  end
end

