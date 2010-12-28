require "spec_helper"
require "rspec/mocks"

describe ChatMessagesController do
  before(:all) do
    RSpec::Mocks::setup(self)
    ::REDIS = double(Object.new)
  end

  describe "#create" do
    before do
      @user = Factory(:user)
      @group = Factory(:group, :founder => @user)

      test_sign_in(@user)
    end

    context "with js format" do
      it "should respond with :created status" do
        ::REDIS.should_receive(:publish)
        post :create, :group_id => @group.id, :chat_message => { :content => "Hi there JS" }, :format => "js"

        response.status.should be == 201
      end

      it "should respond with :bad_request status with invalid data" do
        post :create, :group_id => @group.id, :format => "js"

        response.status.should be == 400
      end
    end

    context "with html format" do
      subject do
        post :create, :group_id => @group.id, :chat_message => { :content => "Hi there" }
      end

      it "should redirect to group_chat_room" do
        ::REDIS.should_receive(:publish)

        subject.should redirect_to(group_chat_room_path(@group))
      end
    end
  end
end
