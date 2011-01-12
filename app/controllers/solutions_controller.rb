class SolutionsController < ApplicationController

  before_filter :authenticate
  before_filter :require_parent_supervision
  require_supervision_step :providing_solutions, :only => [:create, :update]

  def create
    respond_to do |format|
      @solution = @supervision.solutions.build(params[:solution]) do |solution|
        solution.user = current_user
      end
      if @solution.save
        format.js { head :created }
        format.html {
          successful_flash("Solution submited")
          redirect_to supervision_path(@supervision)
        }
      else
        format.js { head :bad_request }
        format.html {
          error_flash("You must provide solution")
          redirect_to supervision_path(@supervision)
        }
      end
    end
  end

  def update
    respond_to do |format|
      @solution = @supervision.solutions.find(params[:id])
      if @solution.update_attributes(params[:solution])
        format.js { head :ok }
        format.html {
          successful_flash("Solution rated")
          redirect_to supervision_path(@supervision)
        }
      else
        format.js { head :bad_request }
        format.html {
          redirect_to supervision_path(@supervision)
        }
      end
    end
  end

  def show
    @solution = @supervision.solutions.find(params[:id])
    render(
      :partial => "solution",
      :layout => false,
      :locals => { :solution => @solution }
    ) if params[:partial]
  end
end

