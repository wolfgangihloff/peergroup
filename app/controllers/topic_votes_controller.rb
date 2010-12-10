class TopicVotesController < ApplicationController

  before_filter :require_parent_supervision
  before_filter :redirect_to_correct_supervision_step

  def new
    @topics = @supervision.topics
    @vote = current_user.votes.build
  end

  def create
    topic = @supervision.topics.find(params[:topic_id])
    vote = topic.votes.build(params[:vote]) do |vote|
      vote.user = current_user
    end
    vote.save!
    successful_flash("Thank you for voting.")
    redirect_to supervision_step_path(@supervision)
  end

  def index
    @topics = @supervision.topics
  end
end

