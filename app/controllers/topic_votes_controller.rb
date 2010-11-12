class TopicVotesController < ApplicationController

  before_filter :require_parent_supervision

  def new
    @topics = @supervision.topics
    @vote = current_user.votes.build
  end

  def create
    @vote = Vote.new(params[:vote])
    @vote.save!
    successful_flash("Thank you for voting.")
    redirect_to supervision_step_path(@supervision)
  end

  def index
    @topics = @supervision.topics
  end
end

