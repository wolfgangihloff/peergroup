class QuestionsController < ApplicationController
  self.responder = SupervisionPartResponder

  before_filter :authenticate
  before_filter :fetch_question, :only => :show
  before_filter :fetch_supervision, :only => :create
  require_supervision_step :asking_questions, :only => :create

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

end
