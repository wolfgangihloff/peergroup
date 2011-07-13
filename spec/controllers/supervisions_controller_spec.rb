require 'spec_helper'

describe SupervisionsController do

  before do
    @group = FactoryGirl.create(:group)
    @user = @group.founder
    sign_in(@user)
  end

  describe "#new" do
    context "when current supervision already exists" do
      before { @supervision = @group.supervisions.create! }

      it "should redirect to show current supervision" do
        get :new, :group_id => @group.id
        response.should redirect_to(supervision_path(@supervision))
      end
    end

    context "when no current supervision" do
      it "should display new supervision question" do
        get :new, :group_id => @group.id
        response.should render_template("new")
      end
    end
  end

  describe "#create" do
    context "when supervision already exists" do
      before do
        @supervision = @group.supervisions.create!
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

  describe "#show" do
    render_views

    before do
      @supervision = FactoryGirl.create(:supervision, :group => @group, :topic => FactoryGirl.create(:topic), :state => "asking_questions")
      @chat_room = @supervision.chat_room
      @user.join_supervision(@supervision)

      SecureRandom.should_receive(:hex).and_return("asdfb")
      REDIS.should_receive(:setex).with("chat:#{@chat_room.id}:token:asdfb", 60, @user.id)
      REDIS.should_receive(:setex).with("supervision:#{@supervision.id}:users:#{@user.id}:token:asdfb", 60, "1")

      get :show, :id => @supervision.id
    end

    specify { response.should be_success }
    specify { assert_tag :attributes => { "class" => "supervision", "id" => "supervision_#{@supervision.id}", "data-token" => "asdfb" } }
  end

  describe "#show for non-member user" do
    before do
      @supervision = FactoryGirl.create(:supervision, :group => @group, :topic => FactoryGirl.create(:topic), :state => "asking_questions")
      get :show, :id => @supervision.id
    end

    specify { response.should redirect_to(new_supervision_membership_path(@supervision)) }
  end

  describe "#update" do
    context "with default format" do
      before do
        @supervision = FactoryGirl.create(:supervision, :group => @group, :state => "providing_solutions")
        @user.join_supervision(@supervision)
        put :update, :id => @supervision.id, :supervision => { :state_event => "step_back_to_providing_ideas" }
      end

      specify { response.should redirect_to(supervision_path(@supervision)) }
    end

    context "with js format" do
      before do
        @supervision = FactoryGirl.create(:supervision, :group => @group, :state => "providing_solutions")
        @user.join_supervision(@supervision)
        put :update, :id => @supervision.id, :supervision => { :state_event => "step_back_to_providing_ideas" }, :format => "js"
      end

      specify { response.should be_success }
    end
  end
end
