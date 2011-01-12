class VotesController < ApplicationController

  before_filter :authenticate
  before_filter :require_parent_supervision
  require_supervision_step :asking_questions, :providing_ideas, :providing_solutions, :only => :create

  def create
    respond_to do |format|
      @vote = @supervision.next_step_votes.build do |vote|
        vote.user = current_user
      end
      if @vote.save
        format.js { head :created }
        format.html { redirect_to supervision_path(@supervision) }
      else
        format.js { head :bad_request }
        format.html { redirect_to supervision_path(@supervision) }
      end
    end
  end

end

