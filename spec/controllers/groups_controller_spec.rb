require 'spec_helper'

describe GroupsController do
  describe "create" do
    before do
      @user = sign_in
    end

    context "when given valid parameters" do
      before do
        post :create, :group => {:name => 'new group', :description => 'funky description'}
      end

      it "should redirect to groups_path" do
        response.should redirect_to(groups_path)
      end

      it "should attach founder" do
        group = Group.first.reload
        group.founder.should == @user
        group.members.should include(@user)
      end
    end

    context "when given invalid parameters" do
      before do
        post :create, :group => {}
      end

      it "should render successfully" do
        response.should be_success
      end

      it "should render new template" do
        response.should render_template('groups/new')
      end
    end

    describe "#current_supervision when there is no supervision in progress" do
      before do
        @group = Factory(:group)
        get :current_supervision, :id => @group.id
      end

      specify { response.should redirect_to(new_group_supervision_path(@group)) }
    end

    describe "#current_sepervision when there is sepervision in progress" do
      before do
        @group = Factory(:group)
        @supervision = Factory(:supervision, :group => @group, :state => "asking_questions")
        get :current_supervision, :id => @group.id
      end

      specify { response.should redirect_to(supervision_path(@supervision)) }
    end
  end
end
