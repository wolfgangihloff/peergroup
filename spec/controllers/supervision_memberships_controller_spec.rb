require 'spec_helper'

describe SupervisionMembershipsController do

  before do
    @group = FactoryGirl.create(:group)
    @user = @group.founder
    sign_in(@user)
    @supervision = FactoryGirl.create(:supervision, :group => @group)
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

    specify { response.should redirect_to(supervisions_path) }
    specify { @supervision.members.should_not include(@user) }
  end

end
