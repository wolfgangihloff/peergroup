class VotesController < ApplicationController
  self.responder = SupervisionPartResponder

  before_filter :authenticate
  before_filter :require_parent_supervision
  require_supervision_state :asking_questions, :providing_ideas, :providing_solutions, :only => :create

  respond_to :html, :json

  def create
    @vote = @supervision.next_step_votes.build do |vote|
      vote.user = current_user
    end
    @vote.save
    respond_with(@vote, :location => @supervision, :no_flash => true)
  end

end

