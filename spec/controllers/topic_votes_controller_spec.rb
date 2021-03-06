require "spec_helper"

describe TopicVotesController do
  before do
    @group = FactoryGirl.create(:group)
    @user = @group.founder
    sign_in(@user)

    @supervision = FactoryGirl.create(:supervision, :group => @group, :state => "voting_on_topics")
    @user.join_supervision(@supervision)
    @topic = FactoryGirl.create(:topic, :supervision => @supervision)
  end

  describe "#create" do
    before do
      post :create, :topic_id => @topic.id
    end

    specify { response.should redirect_to(supervision_path(@supervision)) }
    specify { flash[:notice].should be_present }
  end

  describe "#create.json" do
    before do
      post :create,
        :format => :json,
        :topic_id => @topic.id
    end

    specify { response.should be_success }
    specify do
      json = JSON.restore(response.body)
      json["flash"].should be_present
      json["flash"]["notice"].should be_present
    end
  end
end
