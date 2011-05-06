require "spec_helper"

describe AnswersController do
  before do
    @group = Factory(:group)
    @user = @group.founder
    sign_in(@user)

    @supervision = Factory(:supervision, :group => @group, :state => "asking_questions")
    @question = Factory(:question, :supervision => @supervision)
  end

  describe "#create" do
    describe "with valid data" do
      before do
        post :create,
          :question_id => @question.id,
          :answer => { :content => "Answer content" }
      end

      specify { response.should redirect_to(supervision_path(@supervision)) }
      specify { flash[:notice].should be_present }
    end

    describe "with invalid data" do
      before do
        post :create,
          :question_id => @question.id,
          :answer => {}
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
          :question_id => @question.id,
          :answer => { :content => "Answer content" }
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
          :question_id => @question.id,
          :answer => {}
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
