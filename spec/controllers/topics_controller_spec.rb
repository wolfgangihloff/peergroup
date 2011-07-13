require "spec_helper"

describe TopicsController do

  before do
    @group = FactoryGirl.create(:group)
    @user = @group.founder
    @supervision = FactoryGirl.create(:supervision, :group => @group, :state => "gathering_topics")
    @user.join_supervision(@supervision)

    sign_in(@user)
  end

  describe "#show with partial=1 param" do
    before do
      @topic = FactoryGirl.create(:topic, :supervision => @supervision)
      get :show,
        :supervision_id => @supervision.id,
        :id => @topic.id,
        :partial => 1
    end

    specify { response.should be_success }
    specify { response.should render_template("topic") }
    specify { response.should_not render_template("show") }
  end

  describe "#create" do
    before do
      post :create,
        :supervision_id => @supervision.id,
        :topic => { :content => "Topic content" }
    end

    specify { response.should redirect_to(supervision_path(@supervision)) }
    specify { flash[:notice].should be_present }
  end

  describe "#create.json" do
    before do
      post :create,
        :format => :json,
        :supervision_id => @supervision.id,
        :topic => { :content => "Topic content" }
    end

    specify { response.should be_success }
    specify do
      json = JSON.restore(response.body)
      json["flash"].should be_present
      json["flash"]["notice"].should be_present
    end
  end

  describe "#index" do
    render_views

    before do
      get :index, :supervision_id => @supervision.id
    end

    specify { response.should be_success }
  end

  context "#index" do
    before do
      @supervision = FactoryGirl.create(:supervision, :group => @group, :state => "gathering_topics")
      @user.join_supervision(@supervision)
    end

    describe "partial=topics_votes" do
      before do
        get :index, :supervision_id => @supervision.id
      end

      specify { response.should be_success }
      specify { response.should render_template("supervision_topics_votes") }
      specify { response.should_not render_template("index") }
    end
  end

  describe "#index when @supervision.state=asking_questions" do
    before do
      @supervision = FactoryGirl.create(:supervision, :state => "asking_questions")
      @user.join_supervision(@supervision)
      get :index, :supervision_id => @supervision.id
    end

    specify { response.should redirect_to(supervision_path(@supervision)) }
  end

  describe "#index when @supervision.state=providing_ideas" do
    before do
      @supervision = FactoryGirl.create(:supervision, :state => "providing_ideas")
      @user.join_supervision(@supervision)
      get :index, :supervision_id => @supervision.id
    end

    specify { response.should redirect_to(supervision_path(@supervision)) }
  end

  describe "#index when @supervision.state=giving_ideas_feedback" do
    before do
      @supervision = FactoryGirl.create(:supervision, :state => "giving_ideas_feedback")
      @user.join_supervision(@supervision)
      get :index, :supervision_id => @supervision.id
    end

    specify { response.should redirect_to(supervision_path(@supervision)) }
  end

  describe "#index when @supervision.state=providing_solutions" do
    before do
      @supervision = FactoryGirl.create(:supervision, :state => "providing_solutions")
      @user.join_supervision(@supervision)
      get :index, :supervision_id => @supervision.id
    end

    specify { response.should redirect_to(supervision_path(@supervision)) }
  end

  describe "#index when @supervision.state=giving_solutions_feedback" do
    before do
      @supervision = FactoryGirl.create(:supervision, :state => "giving_solutions_feedback")
      @user.join_supervision(@supervision)
      get :index, :supervision_id => @supervision.id
    end

    specify { response.should redirect_to(supervision_path(@supervision)) }
  end

  describe "#index when @supervision.state=giving_supervision_feedbacks" do
    before do
      @supervision = FactoryGirl.create(:supervision, :state => "giving_supervision_feedbacks")
      @user.join_supervision(@supervision)
      get :index, :supervision_id => @supervision.id
    end

    specify { response.should redirect_to(supervision_path(@supervision)) }
  end
end
