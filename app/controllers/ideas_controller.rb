class IdeasController < ApplicationController

  before_filter :require_parent_supervision

  def index
    @idea = Idea.new unless @supervision.problem_owner?(current_user)
  end

  def create
    idea = @supervision.ideas.build(params[:idea])
    idea.user = current_user
    if idea.save
      successful_flash("Idea successfully submited")
      redirect_to supervision_step_path(@supervision)
    else
      error_flash("You must provide your idea")
      redirect_to ideas_path(:supervision_id => @supervision)
    end
  end

  def update
    idea = @supervision.ideas.find(params[:id])
    idea.update_attributes!(params[:idea])
    successful_flash("Idea rated")
    redirect_to supervision_step_path(@supervision)
  end
end

