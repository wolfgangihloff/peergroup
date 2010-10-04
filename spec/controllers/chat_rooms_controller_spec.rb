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

    it "should show form for newly initialized chat update" do
      get :show, :id => @chat_room.id

      chat_update = assigns[:chat_update]
      expected_path = chat_room_chat_update_path(@chat_room, chat_update)
      response.should have_tag("form[action=?]", expected_path)
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

  describe "POST select_current_rule" do
    before { @rule = @chat_room.group.rules.all.sample }

    def post_with(format)
      post :select_current_rule, :id => @chat_room.id, :rule_id => @rule.id, :format => format
      @chat_room.reload
    end

    context "when requesting html format" do
      before { post_with('html') }

      specify { @response.should redirect_to(chat_room_path(@chat_room)) }
      specify { @chat_room.current_rule.should == @rule }
    end

    context "when requesting js format" do
      before { post_with('json') }

      specify { @response.should be_success }
      specify { @response.body.should be_blank }
      specify { @chat_room.current_rule.should == @rule }
    end
  end
end

