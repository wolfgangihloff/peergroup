require "spec_helper"

describe SolutionsController do
  before do
    @group = FactoryGirl.create(:group)
    @user = @group.founder
    sign_in(@user)

    @supervision = FactoryGirl.create(:supervision, :group => @group, :state => "providing_solutions")
    @user.join_supervision(@supervision)
  end

  describe "#show with partial=1 param" do
    before do
      @solution = FactoryGirl.create(:solution, :supervision => @supervision)
      get :show,
        :id => @solution.id,
        :partial => 1
    end

    specify { response.should be_success }
    specify { response.should render_template("solution") }
    specify { response.should_not render_template("show") }
  end

  describe "#create" do
    describe "with valida data" do
      before do
        post :create,
          :supervision_id => @supervision.id,
          :solution => { :content => "Solution content" }
      end

      specify { response.should redirect_to(supervision_path(@supervision)) }
      specify { flash[:notice].should be_present }
    end

    describe "with invalid data" do
      before do
        post :create,
          :supervision_id => @supervision.id,
          :solution => {}
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
          :solution => { :content => "Solution content" }
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
          :solution => {}
      end

      specify { response.should_not be_success }
      specify do
        json = JSON.restore(response.body)
        json["flash"].should be_present
        json["flash"]["alert"].should be_present
      end
    end
  end

  describe "#update" do
    describe "with valida data" do
      before do
        @solution = FactoryGirl.create(:solution, :supervision => @supervision)
        put :update,
          :id => @solution.id,
          :solution => { :ratign => "3" }
      end

      specify { response.should redirect_to(supervision_path(@supervision)) }
      specify { flash[:notice].should be_present }
    end

    describe "with invalid data" do
      before do
        @solution = FactoryGirl.create(:solution, :supervision => @supervision)
        put :update,
          :id => @solution.id,
          :solution => { :rating => "none" }
      end

      specify { response.should redirect_to(supervision_path(@supervision)) }
      specify { flash[:alert].should be_present }
    end
  end

  describe "#update.json" do
    describe "with valida data" do
      before do
        @solution = FactoryGirl.create(:solution, :supervision => @supervision)
        put :update,
          :format => :json,
          :id => @solution.id,
          :solution => { :rating => "3" }
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
        @solution = FactoryGirl.create(:solution, :supervision => @supervision)
        post :update,
          :format => :json,
          :id => @solution.id,
          :solution => { :rating => "none" }
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
