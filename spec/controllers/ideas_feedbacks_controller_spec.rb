$:.unshift File.join(File.dirname(__FILE__), "..")
require "spec_helper"

describe IdeasFeedbacksController do
  before do
    @group = Factory(:group)
    @user = @group.founder
    sign_in(@user)

    @supervision = Factory(:supervision, :group => @group, :state => "giving_ideas_feedback")
  end

  describe "#show with partial=1 param" do
    before do
      @ideas_feedback = Factory(:ideas_feedback, :supervision => @supervision)
      get :show,
        :supervision_id => @supervision.id,
        :id => @ideas_feedback.id,
        :partial => 1
    end

    specify { response.should be_success }
    specify { response.should render_template("ideas_feedback") }
    specify { response.should_not render_template("show") }
  end

  describe "#create" do
    describe "with valida data" do
      before do
        post :create,
          :supervision_id => @supervision.id,
          :ideas_feedback => { :content => "Ideas feedback content" }
      end

      specify { response.should redirect_to(supervision_path(@supervision)) }
      specify { flash[:notice].should be_present }
    end

    describe "with invalid data" do
      before do
        post :create,
          :supervision_id => @supervision.id,
          :ideas_feedback => {}
      end

      specify { response.should redirect_to(supervision_path(@supervision)) }
      specify { flash[:alert].should be_present }
    end
  end

  describe "#create.json" do
    describe "with valida data" do
      before do
        post :create,
          :format => :json,
          :supervision_id => @supervision.id,
          :ideas_feedback => { :content => "Ideas feedback content" }
      end

      specify { response.should be_success }
      specify do
        json = JSON.restore(response.body)
        json["flash"].should be_present
        json["flash"]["notice"].should be_present
      end
    end

    describe "with invalid data" do
      before do
        post :create,
          :format => :json,
          :supervision_id => @supervision.id,
          :ideas_feedback => {}
      end

      specify { response.should_not be_success }
      specify do
        json = JSON.restore(response.body)
        json["flash"].should be_present
        json["flash"]["alert"].should be_present
      end
    end
  end
end
