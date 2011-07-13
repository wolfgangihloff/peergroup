require 'spec_helper'

describe SessionsController do
  describe "GET 'new'" do

    it "should be successful" do
      get :new
      response.should be_success
    end
  end

  describe "POST 'create'" do

    describe "invalid signin" do

      before(:each) do
        @attr = { :email => "email@example.com", :password => "password" }
        User.should_receive(:authenticate).
             with(@attr[:email], @attr[:password]).
             and_return(nil)
      end

      it "should re-render the new page" do
        post :create, :session => @attr
        response.should render_template('new')
      end
    end

    describe "with valid email and password" do

      before(:each) do
        @user = FactoryGirl.create(:user)
        @attr = { :email => @user.email, :password => @user.password }
        User.should_receive(:authenticate).
             with(@user.email, @user.password).
             and_return(@user)
      end

      it "should sign the user in" do
        post :create, :session => @attr
        controller.current_user.should == @user
        controller.should be_signed_in
      end

      it "should redirect to the user show page" do
        post :create, :session => @attr
        redirect_to user_path(@user)
      end
    end
  end

  describe "DELETE 'destroy'" do

    it "should sign a user out" do
      sign_in
      controller.should be_signed_in
      delete :destroy
      controller.should_not be_signed_in
      response.should redirect_to(root_path)
    end
  end
end
