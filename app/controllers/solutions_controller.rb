class SolutionsController < ApplicationController

  before_filter :require_parent_supervision

  def index
    @solution = Solution.new unless @supervision.problem_owner?(current_user)
    @solutions_feedback = SolutionsFeedback.new

    render :partial => "solutions" if params[:partial]
  end

  def create
    solution = @supervision.solutions.build(params[:solution])
    solution.user = current_user
    if solution.save
      successful_flash("Solution submited")
      redirect_to supervision_step_path(@supervision)
    else
      error_flash("You must provide your solution")
      redirect_to solutions_path(:supervision_id => @supervision.id)
    end
  end

  def update
    solution = @supervision.solutions.find(params[:id])
    solution.update_attributes!(params[:solution])
    successful_flash("Solution rated")
    redirect_to supervision_step_path(@supervision)
  end
end

