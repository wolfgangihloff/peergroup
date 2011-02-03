$:.unshift File.join(File.dirname(__FILE__), "..")
require "spec_helper"

describe VotesController do
  before do
    @group = Factory(:group)
    @user = @group.founder
    test_sign_in(@user)

    @supervision = Factory(:supervision, :group => @group, :state => "providing_ideas")
  end

  describe "#create" do
    before do
      post :create,
        :supervision_id => @supervision.id
    end

    specify { response.should redirect_to(supervision_path(@supervision)) }
    specify { flash[:notice].should_not be_present }
  end

  describe "#create.json" do
    before do
      post :create,
        :format => :json,
        :supervision_id => @supervision.id
    end

    specify { response.should be_success }
    specify do
      json = JSON.restore(response.body)
      json["flash"].should_not be_present
    end
  end
end
