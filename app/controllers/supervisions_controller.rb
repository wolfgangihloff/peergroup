class SupervisionsController < ApplicationController

  respond_to :html

  before_filter :authenticate
  before_filter :require_parent_group, :only => [:new, :create]
  before_filter :check_current_supervision, :only => [:new, :create]
  before_filter :redirect_to_current_supervision_if_exists, :only => [:new, :create]
  before_filter :fetch_supervision, :only => [:show, :update, :statusbar]
  before_filter :redirect_to_topics, :only => [:show]
  before_filter :require_supervision_membership, :only => [:show, :update, :statusbar]

  def index
    @supervisions = current_user.supervisions.in_progress
  end

  def new
    @supervision = @group.supervisions.build
  end

  def create
    redirect_to @group.supervisions.create!
  end

  def show
    @chat_room = @supervision.chat_room
    @chat_messages = @chat_room.chat_messages.recent
    @token = @chat_room.set_redis_access_token_for_user(current_user)
    REDIS.setex("supervision:#{@supervision.id}:users:#{current_user.id}:token:#{@token}", 60, "1")
    @supervision_data = {
      :"supervision-state" => @supervision.state,
      :token => @token,
      :"supervision-state-transitions" => t("supervisions.show.supervision_state_transition").to_json,
      :"supervision-updates" => t("supervisions.show.supervision_updates").to_json
    }
  end

  def update
    respond_to do |format|
      if @supervision.update_attributes(params[:supervision])
        format.js { head :created }
        format.html { redirect_to @supervision }
      else
        format.js { head :bad_request }
        format.html { redirect_to @supervision }
      end
    end
  end

  def statusbar
  end

  protected

  def check_current_supervision
    @supervision = @group.current_supervision
  end

  def redirect_to_current_supervision_if_exists
    return if @supervision.nil? || @supervision.state == "finished"

    redirect_to @supervision
    return false
  end

  def fetch_supervision
    @supervision = Supervision.find(params[:id])
  end

  def redirect_to_topics
    unless @supervision.step_finished?(:voting_on_topics)
      redirect_to supervision_topics_path(@supervision)
    end
  end

  def require_supervision_membership
    unless @supervision.members.exists?(current_user)
      redirect_to new_supervision_membership_path(@supervision)
    end
  end
end
