require "spec_helper"

describe IdeasController do
  before do
    @group = Factory(:group)
    @user = @group.founder
    sign_in(@user)

    @supervision = Factory(:supervision, :group => @group, :state => "providing_ideas")
  end

  describe "#show with partial=1 param" do
    before do
      @idea = Factory(:idea, :supervision => @supervision)
      get :show,
        :id => @idea.id,
        :partial => 1
    end

    specify { response.should be_success }
    specify { response.should render_template("idea") }
    specify { response.should_not render_template("show") }
  end

  describe "#create" do
    describe "with valida data" do
      before do
        post :create,
          :supervision_id => @supervision.id,
          :idea => { :content => "Idea content" }
      end

      specify { response.should redirect_to(supervision_path(@supervision)) }
      specify { flash[:notice].should be_present }
    end

    describe "with invalid data" do
      before do
        post :create,
          :supervision_id => @supervision.id,
          :idea => {}
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
          :idea => { :content => "Idea content" }
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
          :idea => {}
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
        @idea = Factory(:idea, :supervision => @supervision)
        put :update,
          :id => @idea.id,
          :idea => { :ratign => "3" }
      end

      specify { response.should redirect_to(supervision_path(@supervision)) }
      specify { flash[:notice].should be_present }
    end

    describe "with invalid data" do
      before do
        @idea = Factory(:idea, :supervision => @supervision)
        put :update,
          :id => @idea.id,
          :idea => { :rating => "none" }
      end

      specify { response.should redirect_to(supervision_path(@supervision)) }
      specify { flash[:alert].should be_present }
    end
  end

  describe "#update.json" do
    describe "with valida data" do
      before do
        @idea = Factory(:idea, :supervision => @supervision)
        put :update,
          :format => :json,
          :id => @idea.id,
          :idea => { :rating => "3" }
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
        @idea = Factory(:idea, :supervision => @supervision)
        post :update,
          :format => :json,
          :id => @idea.id,
          :idea => { :rating => "none" }
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
