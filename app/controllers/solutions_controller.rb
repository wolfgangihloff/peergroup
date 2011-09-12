class SolutionsController < ApplicationController
  self.responder = SupervisionPartResponder

  before_filter :authenticate_user!
  before_filter :fetch_solution, :only => [:update, :show]
  before_filter :fetch_supervision, :only => :create
  before_filter :require_supervision_membership
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

  def require_supervision_membership
    unless @supervision.members.exists?(current_user)
      redirect_to new_supervision_membership_path(@supervision)
    end
  end
end
