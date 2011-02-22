require 'spec_helper'

describe SupervisionMembershipsController do

  before do
    @group = Factory(:group)
    @user = @group.founder
    sign_in(@user)
    @supervision = Factory(:supervision, :group => @group)
  end

  describe "#create" do
    before do
      post :create, :supervision_id => @supervision.id
    end

    specify { response.should redirect_to(supervision_path(@supervision)) }
    specify { @supervision.members.should include(@user) }
  end

  describe "#destroy" do
    before do
      @user.join_supervision(@supervision)
      delete :destroy, :supervision_id => @supervision.id
    end

    specify { response.should redirect_to(group_path(@group)) }
    specify { @supervision.members.should_not include(@user) }
  end

end
