class TopicVotesController < ApplicationController

  before_filter :require_parent_supervision

  def index
    @topics = @supervision.topics
  end
end
