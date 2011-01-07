class IdeasController < ApplicationController

  before_filter :authenticate
  before_filter :require_parent_supervision
  require_supervision_step :idea, :only => [:create, :update]

  def create
    respond_to do |format|
      @idea = @supervision.ideas.build(params[:idea])
      @idea.user = current_user
      if @idea.save
        format.js { head :created }
        format.html {
          successful_flash("Idea successfully submited")
          redirect_to supervision_path(@supervision)
        }
      else
        format.js { head :bad_request }
        format.html {
          error_flash("You must provide your idea")
          redirect_to supervision_path(@supervision)
        }
      end
    end
  end

  def update
    respond_to do |format|
      @idea = @supervision.ideas.find(params[:id])
      if @idea.update_attributes(params[:idea])
        format.js { head :ok }
        format.html {
          successful_flash("Idea rated")
          redirect_to supervision_path(@supervision)
        }
      else
        format.js { head :bad_reqeust }
        format.html {
          redirect_to supervision_path(@supervision)
        }
      end
    end
  end

  def show
    @idea = @supervision.ideas.find(params[:id])
    render(
      :partial => "idea",
      :layout => false,
      :locals => { :idea => @idea }
    ) if params[:partial]
  end
end

