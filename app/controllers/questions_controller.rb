class QuestionsController < ApplicationController
  self.responder = SupervisionPartResponder

  before_filter :authenticate_user!
  before_filter :fetch_question, :only => :show
  before_filter :fetch_supervision, :only => :create
  before_filter :require_supervision_membership
  require_supervision_state :asking_questions, :only => :create

  respond_to :html, :json

  def create
    @question = @supervision.topic_questions.build(params[:question]) do |question|
      question.user = current_user
    end
    @question.save
    respond_with(@question, :location => @supervision)
  end

  def show
    respond_with(@question)
  end

  protected

  def fetch_question
    @question = Question.find(params[:id])
    @supervision = @question.supervision
  end

  def fetch_supervision
    @supervision = Supervision.find(params[:supervision_id])
  end

  def require_supervision_membership
    unless @supervision.members.exists?(current_user)
      redirect_to new_supervision_membership_path(@supervision)
    end
  end
end
