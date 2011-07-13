class Node::SupervisionMembershipsController < Node::BaseController
  def destroy
    render :text => params.inspect
  end
end
