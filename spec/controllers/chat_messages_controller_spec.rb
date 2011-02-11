require "spec_helper"
require "rspec/mocks"

describe ChatMessagesController do
  before do
    @user = Factory(:user)
    @group = Factory(:group, :founder => @user)
    @chat_room = @group.chat_room

    sign_in(@user)
  end

  describe "#create" do
    before do
      REDIS.should_receive(:publish)
      post :create,
        :group_id => @group.id,
        :chat_room_id => @chat_room.id,
        :chat_message => { :content => "Hi there" }
    end

    specify { subject.should redirect_to(group_chat_room_path(@group)) }
  end

  describe "#create.js" do
    describe "with valid data" do
      before do
        REDIS.should_receive(:publish)
        post :create,
          :group_id => @group.id,
          :chat_room_id => @chat_room.id,
          :chat_message => { :content => "Hi there JS" },
          :format => "js"
      end

      specify { response.should be_success }
    end

    describe "with invalid data" do
      before do
        post :create,
          :group_id => @group.id,
          :chat_room_id => @chat_room.id,
          :chat_message => {},
          :format => "js"
      end

      specify { response.should_not be_success }
    end

  end
end
