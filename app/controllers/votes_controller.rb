class VotesController < ApplicationController

  before_filter :authenticate
  before_filter :require_parent_supervision
  require_supervision_step :topic_question, :idea, :solution

  def create
    vote = @supervision.next_step_votes.build do |vote|
      vote.user = current_user
    end
    vote.save
    redirect_to supervision_path(@supervision)
  end

end

