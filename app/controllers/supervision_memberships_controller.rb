class SupervisionMembershipsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :fetch_supervision
  before_filter :require_supervision_group_membership
  before_filter :require_supervision_in_progress_state, :only => :create

  respond_to :html, :json

  def new
    if @supervision.in_progress?
      current_user.join_supervision(@supervision)
      redirect_to @supervision
    end
  end

  def create
    current_user.join_supervision(@supervision)
    redirect_to @supervision
  end

  def destroy
    current_user.leave_supervision(@supervision)
    redirect_to supervisions_path
  end

  protected

  def fetch_supervision
    @supervision = Supervision.find(params[:supervision_id])
  end

  def require_supervision_group_membership
    unless @supervision.group.active_members.exists?(current_user)
      respond_to do |fomat|
        format.html { redirect_to root_path }
        format.json { render :status => :forbidden, :json => {:status => "forbidden"} }
      end
      false
    end
  end

  def require_supervision_in_progress_state
    unless @supervision.in_progress?
      redirect_to group_path(@supervision.group), :notice => t(".not_in_progress_state", :state => @supervision.state)
    end
  end
end
