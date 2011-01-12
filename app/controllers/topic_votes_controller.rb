class TopicVotesController < ApplicationController

  before_filter :authenticate
  before_filter :require_parent_supervision
  require_supervision_step :voting_on_topics

  def create
    respond_to do |format|
      @topic = @supervision.topics.find(params[:topic_id])
      @vote = @topic.votes.build(params[:vote]) do |vote|
        vote.user = current_user
      end
      if @vote.save
        format.js { head :created }
        format.html {
          successful_flash("Thank you for voting")
          redirect_to supervision_path(@supervision)
        }
      else
        logger.info(@vote.errors.full_messages)
        format.js { head :bad_request }
        format.html {
          redirect_to supervision_path(@supervision)
        }
      end
    end
  end
end

