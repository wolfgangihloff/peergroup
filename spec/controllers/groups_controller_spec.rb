require 'spec_helper'

describe GroupsController do
  describe "create" do
    before do
      @user = Factory(:user)
      test_sign_in @user
    end

    describe "when given valid parameters" do
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

    describe "when given invalid parameters" do
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

  end
end
