class SolutionsController < ApplicationController
  self.responder = SupervisionPartResponder

  before_filter :authenticate
  before_filter :fetch_solution, :only => [:update, :show]
  before_filter :fetch_supervision, :only => :create
  require_supervision_state :providing_solutions, :only => :create

  respond_to :html, :json

  def create
    @solution = @supervision.solutions.build(params[:solution]) do |solution|
      solution.user = current_user
    end
    @solution.save
    respond_with(@solution, :location => @supervision)
  end

  def update
    @solution.update_attributes(params[:solution])
    respond_with(@solution, :location => @supervision)
  end

  def show
    respond_with(@solution)
  end

  protected

  def fetch_solution
    @solution = Solution.find(params[:id])
    @supervision = @solution.supervision
  end

  def fetch_supervision
    @supervision = Supervision.find(params[:supervision_id])
  end
end

