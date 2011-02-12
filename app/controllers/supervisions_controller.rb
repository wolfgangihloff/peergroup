class SupervisionsController < ApplicationController

  respond_to :html

  before_filter :authenticate
  before_filter :require_parent_group, :only => [:new, :create]
  before_filter :check_current_supervision, :only => [:new, :create]
  before_filter :redirect_to_current_supervision_if_exists, :only => [:new, :create]
  before_filter :fetch_supervision, :only => [:show,:update]
  before_filter :redirect_to_topics, :only => [:show]

  def index
    @finished_supervisions = Supervision.finished.where(:group_id => current_user.group_ids).paginate :per_page => 10, :page => params[:page], :order => "created_at DESC"
    @current_supervisions = Supervision.unfinished.where(:group_id => current_user.group_ids)
  end

  def new
    @supervision = @group.supervisions.build
  end

  def create
    redirect_to @group.supervisions.create!
  end

  def show
    @chat_room = @supervision.chat_room
    @chat_messages = @chat_room.last_messages
    @token = SecureRandom.hex
    REDIS.setex("supervision:#{@supervision.id}:users:#{current_user.id}:token:#{@token}", 60, "1")
    REDIS.setex("chat:#{@supervision.chat_room_id}:users:#{current_user.id}:token:#{@token}", 60, "1")
  end

  def update
    respond_to do |format|
      if @supervision.update_attributes!(params[:supervision])
        format.js { head :created }
        format.html { redirect_to @supervision }
      else
        format.js { head :bad_request }
        format.html { redirect_to @supervision }
      end
    end
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

end

