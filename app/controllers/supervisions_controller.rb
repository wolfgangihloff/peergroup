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
    redirect_to @group.supervisions.create!
  end

  def show
    @supervision = Supervision.find(params[:id])
    @token = SecureRandom.hex
    REDIS.setex("supervision:#{@supervision.id}:users:#{current_user.id}:token:#{@token}", 60, "1")
  end

  def topics_votes_view
    @supervision = Supervision.find(params[:id])
    if params[:partial]
      render :partial => "supervision_topic_vote", :layout => false
    end
  end
  def topic_questions_view
    @supervision = Supervision.find(params[:id])
    if params[:partial]
      render :partial => "supervision_topic_question", :layout => false
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
end

