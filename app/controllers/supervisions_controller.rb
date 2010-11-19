class SupervisionsController < ApplicationController

  respond_to :html

  before_filter :require_parent_group, :only => [:new, :create]
  before_filter :check_current_supervision, :only => [:new, :create]
  before_filter :redirect_to_current_supervision_if_exists, :only => [:new, :create]

  def new
    @supervision = @group.supervisions.build
  end

  def create
    redirect_to supervision_path(@group.supervisions.create!)
  end

  def show
    @supervision = Supervision.find(params[:id])
    redirect_to new_topic_path(:supervision_id => @supervision.id)
  end

  protected

  def check_current_supervision
    @supervision = @group.current_supervision
  end

  def redirect_to_current_supervision_if_exists
    return true if @supervision.nil? || @supervision.state == "finished"

    redirect_to supervision_path(@supervision)
    return false
  end
end

