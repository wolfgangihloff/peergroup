class SolutionsController < ApplicationController
  self.responder = SupervisionPartResponder

  before_filter :authenticate
  before_filter :require_parent_supervision
  require_supervision_step :providing_solutions, :only => [:create, :update]

  respond_to :html, :json

  def create
    @solution = @supervision.solutions.build(params[:solution]) do |solution|
      solution.user = current_user
    end
    @solution.save
    respond_with(@solution, :location => @supervision)
  end

  def update
    @solution = @supervision.solutions.find(params[:id])
    @solution.update_attributes(params[:solution])
    respond_with(@solution, :location => @supervision)
  end

  def show
    @solution = @supervision.solutions.find(params[:id])
    respond_with(@solution)
  end
end

