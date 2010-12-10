class SupervisionsController < ApplicationController

  respond_to :html

  before_filter :authenticate
  before_filter :require_parent_group, :only => [:new, :create]
  before_filter :check_current_supervision, :only => [:new, :create]
  before_filter :redirect_to_current_supervision_if_exists, :only => [:new, :create]

  def index
    @finished_supervisions = Supervision.finished.where(:group_id => current_user.group_ids).paginate :per_page => 10, :page => params[:page], :order => "created_at DESC"
    @current_supervisions = Supervision.unfinished.where(:group_id => current_user.group_ids)
  end

  def new
    @supervision = @group.supervisions.build
  end

  def create
    redirect_to supervision_path(@group.supervisions.create!)
  end

  def show
    @supervision = Supervision.find(params[:id])
  end

  protected

  def check_current_supervision
    @supervision = @group.current_supervision
  end

  def redirect_to_current_supervision_if_exists
    return if @supervision.nil? || @supervision.state == "finished"

    redirect_to supervision_path(@supervision)
    return false
  end
end

