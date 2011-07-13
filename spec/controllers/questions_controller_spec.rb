require "spec_helper"

describe QuestionsController do
  before do
    @group = FactoryGirl.create(:group)
    @user = @group.founder
    sign_in(@user)

    @supervision = FactoryGirl.create(:supervision, :group => @group, :state => "asking_questions")
    @user.join_supervision(@supervision)
  end

  describe "#show with partial=1 param" do
    before do
      @question = FactoryGirl.create(:question, :supervision => @supervision)
      get :show,
        :id => @question.id,
        :partial => 1
    end

    specify { response.should be_success }
    specify { response.should render_template("question") }
    specify { response.should_not render_template("show") }
  end

  describe "#create" do
    describe "with valid data" do
      before do
        post :create,
          :supervision_id => @supervision.id,
          :question => { :content => "Question content" }
      end

      specify { response.should redirect_to(supervision_path(@supervision)) }
      specify { flash[:notice].should be_present }
    end

    describe "with invalid data" do
      before do
        post :create,
          :supervision_id => @supervision.id,
          :question => {}
      end

      specify { response.should redirect_to(supervision_path(@supervision)) }
      specify { flash[:alert].should be_present }
    end
  end

  describe "#create.json" do
    describe "with valid data" do
      before do
        post :create,
          :format => :json,
          :supervision_id => @supervision.id,
          :question => { :content => "Question content" }
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
          :question => {}
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
