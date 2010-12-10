class SolutionsController < ApplicationController

  before_filter :authenticate
  before_filter :require_parent_supervision
  require_supervision_step :solution

  def create
    solution = @supervision.solutions.build(params[:solution]) do |solution|
      solution.user = current_user
    end
    if solution.save
      successful_flash("Solution submited")
    else
      error_flash("You must provide solution")
    end
    redirect_to supervision_path(@supervision)
  end

  def update
    solution = @supervision.solutions.find(params[:id])
    if solution.update_attributes(params[:solution])
      successful_flash("Solution rated")
    end
    redirect_to supervision_path(@supervision)
  end
end

