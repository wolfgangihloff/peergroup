class QuestionsController < ApplicationController
  self.responder = SupervisionPartResponder

  before_filter :authenticate
  before_filter :require_parent_supervision
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
    @question = @supervision.questions.find(params[:id])
    respond_with(@question)
  end

end
