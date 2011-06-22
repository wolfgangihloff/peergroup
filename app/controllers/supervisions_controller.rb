class SupervisionsController < ApplicationController
  respond_to :html

  before_filter :authenticate
  before_filter :redirect_to_current_supervision_if_exists, :only => [:new, :create]
  before_filter :require_supervision_membership, :only => [:show, :update, :statusbar]

  def index
    @supervisions = current_user.supervisions.in_progress
  end

  def new
    @supervision = group.supervisions.build
  end

  def create
    @supervision = group.supervisions.create!
    current_user.join_supervision(@supervision)
    redirect_to @supervision
  end

  def show
    @chat_room = supervision.chat_room
    @chat_messages = @chat_room.chat_messages.recent
    @token = @chat_room.set_redis_access_token_for_user(current_user)
    REDIS.setex("supervision:#{supervision.id}:users:#{current_user.id}:token:#{@token}", 60, "1")
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

  protected

  def redirect_to_current_supervision_if_exists
    return if group.current_supervision.nil? || group.current_supervision.finished?
    redirect_to group.current_supervision
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
