class IdeasController < ApplicationController

  before_filter :authenticate
  before_filter :require_parent_supervision
  require_supervision_step :idea

  def create
    idea = @supervision.ideas.build(params[:idea])
    idea.user = current_user
    if idea.save
      successful_flash("Idea successfully submited")
    else
      error_flash("You must provide your idea")
    end
    redirect_to supervision_path(@supervision)
  end

  def update
    idea = @supervision.ideas.find(params[:id])
    if idea.update_attributes(params[:idea])
      successful_flash("Idea rated")
    end
    redirect_to supervision_path(@supervision)
  end
end

