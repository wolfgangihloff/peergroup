class SolutionsController < ApplicationController

  before_filter :require_parent_supervision
  require_supervision_step :solution, :solution_feedback

  def index
    @solution = Solution.new unless @supervision.problem_owner?(current_user)
    @solutions_feedback = SolutionsFeedback.new

    render :partial => "solutions" if params[:partial]
  end

  def create
    solution = @supervision.solutions.build(params[:solution]) do |solution|
      solution.user = current_user
    end
    solution.save!
    successful_flash("Solution submited")
    redirect_to supervision_step_path(@supervision)
  end

  def update
    solution = @supervision.solutions.find(params[:id])
    unless solution.rating
      solution.rating = params[:solution][:rating]
      solution.save!
      successful_flash("Solution rated")
    end
    redirect_to supervision_step_path(@supervision)
  end
end

