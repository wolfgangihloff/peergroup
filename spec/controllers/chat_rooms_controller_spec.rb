require 'spec_helper'

describe ChatRoomsController do
  integrate_views

  before do
    @group = Factory(:group)
    @chat_room = @group.chat_room
    @user = Factory(:user)
    test_sign_in(@user)
  end

  describe "GET show" do
    it "should show Problem owner links to the leader" do
      @chat_room.update_attributes(:leader => @user)
      get :show, :id => @chat_room.id
      response.should have_tag("ul.chatting_users a", :text => "Problem owner")
    end

    it "should not show Problem owner link to a member" do
      get :show, :id => @chat_room.id
      response.should_not have_tag("ul.chatting_users a", :text => "Problem owner")
    end
  end

  describe "POST select_leader" do
    it "should mark user as a leader" do
      post :select_leader, :id => @chat_room.id, :user_id => @user.id
      @chat_room.reload.leader.should == @user
    end

    it "should redirect to chat_room page" do
      post :select_leader, :id => @chat_room.id, :user_id => @user.id
      response.should redirect_to(chat_room_path(@chat_room))
    end
  end

  describe "POST select_problem_owner" do
    it "should mark user as a problem owner" do
      post :select_problem_owner, :id => @chat_room.id, :user_id => @user.id
      @chat_room.reload.problem_owner.should == @user
    end

    it "should redirect to chat_room page" do
      post :select_problem_owner, :id => @chat_room.id, :user_id => @user.id
      response.should redirect_to(chat_room_path(@chat_room))
    end
  end
end

