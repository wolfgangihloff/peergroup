class AnswersController < ApplicationController
  self.responder = SupervisionPartResponder

  before_filter :authenticate
  before_filter :fetch_question
  require_supervision_step :asking_questions, :only => :create

  respond_to :html, :json

  def create
    @answer = @question.build_answer(params[:answer])
    @answer.user = current_user
    @answer.save
    respond_with(@answer, :location => @supervision)
  end

  protected

  def fetch_question
    @question = Question.find(params[:question_id])
    @supervision = @question.supervision
  end

end

