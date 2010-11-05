require 'spec_helper'

describe ChatRoomsController do
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

  context "roles selection" do
    def post_select(role)
      post "select_#{role}", :id => @chat_room.id, :user_id => @user.id
      @chat_room.reload
    end

    describe "POST select_leader" do
      before { post_select('leader') }

      specify { @response.should be_success }
      specify { @response.body.should be_blank }
      specify { @chat_room.leader.should == @user }
    end

    describe "POST select_problem_owner" do
      before { post_select('problem_owner') }

      specify { @response.should be_success }
      specify { @response.body.should be_blank }
      specify { @chat_room.problem_owner.should == @user }
    end
  end

  describe "POST select_current_rule" do
    before do
      @rule = @chat_room.group.rules.all.sample
      post :select_current_rule, :id => @chat_room.id, :rule_id => @rule.id
      @chat_room.reload
    end

    context "when requesting js format" do
      specify { @response.should be_success }
      specify { @response.body.should be_blank }
      specify { @chat_room.current_rule.should == @rule }
    end
  end
end

