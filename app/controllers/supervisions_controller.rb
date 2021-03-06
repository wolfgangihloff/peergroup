class SupervisionsController < ApplicationController
  respond_to :html

  before_filter :authenticate_user!
  before_filter :redirect_to_current_supervision_if_exists, :only => [:new, :create]
  before_filter :require_supervision_membership, :only => [:show, :update, :statusbar]

  def index
    @supervisions = current_user.supervisions.in_progress
  end

  def new
    @supervision = group.supervisions.build
  end

  def create
    @supervision = group.supervisions.current || group.supervisions.create!
    current_user.join_supervision(@supervision)
    redirect_to @supervision
  end

  def show
    @chat_room = supervision.chat_room
    @chat_messages = @chat_room.chat_messages.recent
    @token = @chat_room.set_redis_access_token_for_user(current_user)
    @topic = current_user.last_proposed_topic(@supervision.group).clone
    REDIS.setex("supervision:#{supervision.id}:users:#{current_user.id}:token:#{@token}", 120, "1")
    @supervision_data = {
      :"supervision-state" => supervision.state,
      :token => @token,
      :"supervision-state-transitions" => t("supervisions.show.supervision_state_transition").to_json,
      :"supervision-updates" => t("supervisions.show.supervision_updates").to_json,
      :"current-user-id" => current_user.id,
      :"supervision-topic-user-id" => supervision.topic.try(:user_id)
    }
  end

  def update
    respond_to do |format|
      if supervision.update_attributes(params[:supervision])
        format.js { head :created }
        format.html { redirect_to supervision }
      else
        format.js { head :bad_request }
        format.html { redirect_to supervision }
      end
    end
  end

  def statusbar
    supervision
  end

  def cancel
    flash[:notice] = t("supervision.cancelled", :default => "Supervision was cancelled") 
    redirect_to group_path(supervision.group)
  end

  def remove
    flash[:notice] = t("supervision.removed", :default => "You were removed from supervision due to inactivity")
    redirect_to group_path(supervision.group)
  end

  protected

  def redirect_to_current_supervision_if_exists
    if current_supervision = group.supervisions.current
      redirect_to current_supervision
    end
  end

  def require_supervision_membership
    unless supervision.members.exists?(current_user)
      redirect_to new_supervision_membership_path(supervision)
    end
  end

  def group
    @group ||= Group.find(params[:group_id])
  end

  def supervision
    @supervision ||= Supervision.find(params[:id])
  end
end
