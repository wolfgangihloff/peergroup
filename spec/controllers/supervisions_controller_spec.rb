require 'spec_helper'

describe SupervisionsController do

  before do
    @group = Factory(:group)
    @user = @group.founder
    test_sign_in(@user)
  end

  def mock_current_supervision_with(supervision)
    Group.should_receive(:find).with(@group.id).and_return(@group)
    @group.should_receive(:current_supervision).and_return(supervision)
  end

  describe "#new" do
    context "when current supervision already exists" do
      before { mock_current_supervision_with(@supervision = @group.supervisions.create!) }

      it "should redirect to show current supervision" do
        get :new, :group_id => @group.id
        response.should redirect_to(supervision_path(@supervision))
      end
    end

    context "when no current supervision" do
      before { mock_current_supervision_with(nil) }

      it "should display new supervision question" do
        get :new, :group_id => @group.id
        response.should render_template("new")
      end
    end
  end

  describe "#create" do

    context "when supervision already exists" do
      before do
        mock_current_supervision_with(@supervision = @group.supervisions.create!)
        post :create, :group_id => @group.id
      end

      specify { response.should redirect_to(supervision_path(@supervision)) }
      specify { @group.supervisions.count.should == 1 }
    end

    context "when no current supervision" do
      before do
        post :create, :group_id => @group.id
        @current_supervision = @group.current_supervision
      end

      specify { @current_supervision.should_not be_nil }
      specify { response.should redirect_to(supervision_path(@current_supervision)) }
    end
  end

  describe "#show with supervision.state=gathering_topics" do
    before do
      @supervision = @group.supervisions.create!(:state => "topics")
      get :show, :id => @supervision.id
    end

    specify { response.should redirect_to(supervision_topics_path(@supervision)) }
  end

  describe "#show" do
    render_views

    before do
      @supervision = Factory(:supervision, :group => @group, :topic => Factory(:topic), :state => "asking_questions")
      SecureRandom.should_receive(:hex).and_return("asdfb")
      ::REDIS.should_receive(:setex).with("supervision:#{@supervision.id}:users:#{@user.id}:token:asdfb", 60, "1")
      get :show, :id => @supervision.id
    end

    specify { response.should be_success }
    specify { assert_tag :attributes => { "class" => "supervision", "id" => "supervision_#{@supervision.id}", "data-token" => "asdfb" } }
  end

  #describe "#show with partial" do
    #before { @supervision = @group.supervisions.create! }

    #describe "topic_votes" do
      #before { get :show, :id => @supervision.id, :partial => "topic_votes" }

      #specify { response.should be_success }
      #specify { response.should render_template("supervision_topic_votes") }
      #specify { response.should_not render_template("show") }
    #end

    #describe "questions" do
      #before { get :show, :id => @supervision.id, :partial => "questions" }

      #specify { response.should be_success }
      #specify { response.should render_template("supervision_questions") }
      #specify { response.should_not render_template("show") }
    #end

    #describe "ideas" do
      #before { get :show, :id => @supervision.id, :partial => "ideas" }

      #specify { response.should be_success }
      #specify { response.should render_template("supervision_ideas") }
      #specify { response.should_not render_template("show") }
    #end

    #describe "ideas_feedback" do
      #before { get :show, :id => @supervision.id, :partial => "ideas_feedback" }

      #specify { response.should be_success }
      #specify { response.should render_template("supervision_ideas_feedback") }
      #specify { response.should_not render_template("show") }
    #end

    #describe "solutions" do
      #before { get :show, :id => @supervision.id, :partial => "solutions" }

      #specify { response.should be_success }
      #specify { response.should render_template("supervision_solutions") }
      #specify { response.should_not render_template("show") }
    #end

    #describe "solutions_feedback" do
      #before { get :show, :id => @supervision.id, :partial => "solutions_feedback" }

      #specify { response.should be_success }
      #specify { response.should render_template("supervision_solutions_feedback") }
      #specify { response.should_not render_template("show") }
    #end

    #describe "supervision_feedback" do
      #before { get :show, :id => @supervision.id, :partial => "supervision_feedbacks" }

      #specify { response.should be_success }
      #specify { response.should render_template("supervision_supervision_feedbacks") }
      #specify { response.should_not render_template("show") }
    #end

    #describe "finished" do
      #before { get :show, :id => @supervision.id, :partial => "finished" }

      #specify { response.should be_success }
      #specify { response.should render_template("supervision_finished") }
      #specify { response.should_not render_template("show") }
    #end
  #end

  describe "#update" do
    context "with default format" do
      before do
        @supervision = Factory(:supervision, :group => @group, :state => "providing_solutions")
        put :update, :id => @supervision.id, :supervision => { :state_event => "step_back_to_providing_ideas" }
      end

      specify { response.should redirect_to(supervision_path(@supervision)) }
    end

    context "with js format" do
      before do
        @supervision = Factory(:supervision, :group => @group, :state => "providing_solutions")
        put :update, :id => @supervision.id, :supervision => { :state_event => "step_back_to_providing_ideas" }, :format => "js"
      end

      specify { response.should be_success }
    end
  end
end

