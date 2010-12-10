class IdeasController < ApplicationController

  before_filter :require_parent_supervision
  require_supervision_step :idea, :idea_feedback

  def index
    @idea = Idea.new unless @supervision.problem_owner?(current_user)
    @ideas_feedback = IdeasFeedback.new

    render :partial => "ideas" if params[:partial]
  end

  def create
    idea = @supervision.ideas.build(params[:idea])
    idea.user = current_user
    if idea.save
      successful_flash("Idea successfully submited")
      redirect_to supervision_step_path(@supervision)
    else
      error_flash("You must provide your idea")
      redirect_to supervision_ideas_path(@supervision.id)
    end
  end

  def update
    idea = @supervision.ideas.find(params[:id])
    unless idea.rating
      idea.rating = params[:idea][:rating]
      idea.save!
      successful_flash("Idea rated")
    end
    redirect_to supervision_step_path(@supervision)
  end
end

