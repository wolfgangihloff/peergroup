class TopicVotesController < ApplicationController
  self.responder = SupervisionPartResponder

  before_filter :authenticate
  before_filter :require_supervision_membership
  require_supervision_state :voting_on_topics

  respond_to :html, :json

  def create
    @vote = topic.votes.build
    @vote.user = current_user
    @vote.save
    respond_with(@vote, :location => supervision_topics_path(supervision))
  end

  protected

  def topic
    @topic ||= Topic.find(params[:topic_id])
  end

  def supervision
    @supervision ||= topic.supervision
  end

  def require_supervision_membership
    unless supervision.members.exists?(current_user)
      redirect_to new_supervision_membership_path(supervision)
    end
  end
end
