class SupervisionsController < ApplicationController

  respond_to :html

  before_filter :authenticate
  before_filter :require_parent_group, :only => [:new, :create]
  before_filter :check_current_supervision, :only => [:new, :create]
  before_filter :redirect_to_current_supervision_if_exists, :only => [:new, :create]
  before_filter :fetch_supervision, :only => [
    :topic_votes_view, :topic_questions_view, :ideas_view, :ideas_feedback_view,
    :ideas_feedback_view, :solutions_view, :solutions_feedback_view, :supervision_feedback_view
  ]

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
    "topics_votes" => "supervision_topic_vote",
    "questions" => "supervision_topic_question",
    "ideas" => "supervision_idea",
    "ideas_feedback" => "supervision_idea_feedback",
    "solutions" => "supervision_solution",
    "solutions_feedback" => "supervision_solution_feedback",
    "supervision_feedbacks" => "supervision_supervision_feedback",
    "finished" => "supervision_finished"
  }

  def fetch_supervision
    @supervision = Supervision.find(params[:id])
  end

  def check_current_supervision
    @supervision = @group.current_supervision
  end

  def redirect_to_current_supervision_if_exists
    return if @supervision.nil? || @supervision.state == "finished"

    redirect_to @supervision
    return false
  end
end

