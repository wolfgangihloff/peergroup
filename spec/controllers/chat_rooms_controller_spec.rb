require "spec_helper"
require "rspec/mocks"

describe ChatRoomsController do
  before(:all) do
    RSpec::Mocks::setup(self)
    ::REDIS = double(Object.new)
  end

  describe "#show" do
    before do
      @user = Factory(:user, :id => 1)
      @group = Factory(:group, :founder => @user)
      test_sign_in(@user)
    end

    it "should set token in Redis for user access" do
      @chat_room = @group.chat_room
      SecureRandom.should_receive(:hex) { "asdfb" }
      ::REDIS.should_receive(:setex).with("chat:#{@chat_room.id}:users:1:token:asdfb", 60, "1")
      get :show, :group_id => @group.id, :id => @chat_room
    end
  end
end
