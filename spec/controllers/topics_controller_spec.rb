$:.unshift File.join(File.dirname(__FILE__), "..")
require "spec_helper"

describe TopicsController do

  before do
    @group = Factory(:group)
    @user = @group.founder
    test_sign_in(@user)
  end

  def mock_current_supervision_with(supervision)
    Group.should_receive(:find).with(@group.id).and_return(@group)
    @group.should_receive(:current_supervision).and_return(supervision)
  end

  describe "#create" do
    # TODO
  end

  describe "#show" do
    # TODO
  end

  describe "#index" do
    render_views

    before do
      @supervision = Factory(:supervision, :group => @group, :state => "gathering_topics")
      SecureRandom.should_receive(:hex).and_return("asdfb")
      ::REDIS.should_receive(:setex).with("supervision:#{@supervision.id}:users:#{@user.id}:token:asdfb", 60, "1")
      get :index, :supervision_id => @supervision.id
    end

    specify { response.should be_success }
    specify { assert_tag :attributes => { "class" => "supervision", "id" => "supervision_#{@supervision.id}", "data-token" => "asdfb" } }
  end
  context "#index with param" do
    before do
      @supervision = Factory(:supervision, :group => @group, :state => "gathering_topics")
    end

    describe "partial=topics" do
      before do
        get :index, :supervision_id => @supervision.id, :partial => "topics"
      end

      specify { response.should be_success }
      specify { response.should render_template("supervision_topics") }
      specify { response.should_not render_template("index") }
    end

    describe "partial=topics_votes" do
      before do
        get :index, :supervision_id => @supervision.id, :partial => "topics_votes"
      end

      specify { response.should be_success }
      specify { response.should render_template("supervision_topics_votes") }
      specify { response.should_not render_template("index") }
    end
  end

  describe "#index when @supervision.state=gathering_topics" do
    before do
      @supervision = Factory(:supervision, :state => "gathering_topics")
      SecureRandom.should_receive(:hex).and_return("asdfb")
      ::REDIS.should_receive(:setex).with("supervision:#{@supervision.id}:users:#{@user.id}:token:asdfb", 60, "1")
      get :index, :supervision_id => @supervision.id
    end

    specify { response.should be_success }
  end

  describe "#index when @supervision.state=voting_on_topics" do
    before do
      @supervision = Factory(:supervision, :state => "voting_on_topics")
      SecureRandom.should_receive(:hex).and_return("asdfb")
      ::REDIS.should_receive(:setex).with("supervision:#{@supervision.id}:users:#{@user.id}:token:asdfb", 60, "1")
      get :index, :supervision_id => @supervision.id
    end

    specify { response.should be_success }
  end

  describe "#index when @supervision.state=asking_questions" do
    before do
      @supervision = Factory(:supervision, :state => "asking_questions")
      get :index, :supervision_id => @supervision.id
    end

    specify { response.should redirect_to(supervision_path(@supervision)) }
  end

  describe "#index when @supervision.state=providing_ideas" do
    before do
      @supervision = Factory(:supervision, :state => "providing_ideas")
      get :index, :supervision_id => @supervision.id
    end

    specify { response.should redirect_to(supervision_path(@supervision)) }
  end

  describe "#index when @supervision.state=giving_ideas_feedback" do
    before do
      @supervision = Factory(:supervision, :state => "giving_ideas_feedback")
      get :index, :supervision_id => @supervision.id
    end

    specify { response.should redirect_to(supervision_path(@supervision)) }
  end

  describe "#index when @supervision.state=providing_solutions" do
    before do
      @supervision = Factory(:supervision, :state => "providing_solutions")
      get :index, :supervision_id => @supervision.id
    end

    specify { response.should redirect_to(supervision_path(@supervision)) }
  end

  describe "#index when @supervision.state=giving_solutions_feedback" do
    before do
      @supervision = Factory(:supervision, :state => "giving_solutions_feedback")
      get :index, :supervision_id => @supervision.id
    end

    specify { response.should redirect_to(supervision_path(@supervision)) }
  end

  describe "#index when @supervision.state=giving_supervision_feedbacks" do
    before do
      @supervision = Factory(:supervision, :state => "giving_supervision_feedbacks")
      get :index, :supervision_id => @supervision.id
    end

    specify { response.should redirect_to(supervision_path(@supervision)) }
  end
end

