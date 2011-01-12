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
    if params[:partial]
      partial_name = PARTIAL_NAMES[params[:partial]]
      render :partial => partial_name, :layout => false
    else
      @token = SecureRandom.hex
      REDIS.setex("supervision:#{@supervision.id}:users:#{current_user.id}:token:#{@token}", 60, "1")
    end
  end

  protected

  PARTIAL_NAMES = {
    "topic_votes"           => "supervision_topic_votes",
    "questions"             => "supervision_questions",
    "ideas"                 => "supervision_ideas",
    "ideas_feedback"        => "supervision_ideas_feedback",
    "solutions"             => "supervision_solutions",
    "solutions_feedback"    => "supervision_solutions_feedback",
    "supervision_feedbacks" => "supervision_supervision_feedbacks",
    "finished"              => "supervision_finished"
  }

  def check_current_supervision
    @supervision = @group.current_supervision
  end

  def redirect_to_current_supervision_if_exists
    return if @supervision.nil? || @supervision.state == "finished"

    redirect_to @supervision
    return false
  end
end

