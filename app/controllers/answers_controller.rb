class AnswersController < ApplicationController
  self.responder = SupervisionPartResponder

  before_filter :authenticate_user!
  before_filter :require_supervision_membership
  require_supervision_state :asking_questions, :giving_answers, :only => :create

  respond_to :html, :json

  def create
    @answer = question.build_answer(params[:answer])
    @answer.user = current_user
    @answer.save
    respond_with(@answer, :location => supervision)
  end

  protected

  def question
    @question ||= Question.find(params[:question_id])
  end

  def supervision
    @supervision ||= question.supervision
  end

  def require_supervision_membership
    unless supervision.members.exists?(current_user)
      redirect_to new_supervision_membership_path(supervision)
    end
  end
end
