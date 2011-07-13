require "spec_helper"

describe VotesController do
  before do
    @group = FactoryGirl.create(:group)
    @user = @group.founder
    sign_in(@user)

    @supervision = FactoryGirl.create(:supervision, :group => @group, :state => "providing_ideas")
    @user.join_supervision(@supervision)
  end

  describe "#create" do
    before do
      post :create, :supervision_id => @supervision.id
    end

    specify { response.should redirect_to(supervision_path(@supervision)) }
  end

  describe "#create.json" do
    before do
      post :create,
        :format => :json,
        :supervision_id => @supervision.id
    end

    specify { response.should be_success }
  end
end
