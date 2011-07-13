class Node::MembersController < Node::BaseController
  respond_to :json

  def destroy
    @membership = supervision.memberships.find_by_user_id!(params[:id])
    @membership.destroy
    Rails.logger.info(@membership.inspect)
    respond_with @membership
  end

  private

  def supervision
    @supervision ||= Supervision.find(params[:supervision_id])
  end
end
