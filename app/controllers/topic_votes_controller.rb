class TopicVotesController < ApplicationController

  before_filter :authenticate
  before_filter :require_parent_supervision
  require_supervision_step :topic_vote

  def create
    topic = @supervision.topics.find(params[:topic_id])
    vote = topic.votes.build(params[:vote]) do |vote|
      vote.user = current_user
    end
    if vote.save
      successful_flash("Thank you for voting")
    end
    redirect_to supervision_path(@supervision)
  end
end

