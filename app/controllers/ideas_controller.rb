class IdeasController < ApplicationController
  self.responder = SupervisionPartResponder

  before_filter :authenticate
  before_filter :require_parent_supervision
  require_supervision_step :providing_ideas, :only => [:create, :update]

  respond_to :html, :json

  def create
    @idea = @supervision.ideas.build(params[:idea]) do |idea|
      idea.user = current_user
    end
    @idea.save
    respond_with(@idea, :location => @supervision)
  end

  def update
    @idea = @supervision.ideas.find(params[:id])
    @idea.update_attributes(params[:idea])
    respond_with(@idea, :location => @supervision)
  end

  def show
    @idea = @supervision.ideas.find(params[:id])
    respond_with(@idea)
  end
end

