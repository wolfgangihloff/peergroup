require "spec_helper"

describe ChatRoom do
  describe "group attribute" do
    it "should be required" do
      @chat_room = Factory.build(:chat_room, :group => nil)
      @chat_room.should_not be_valid
      @chat_room.should have(1).error_on(:group)
    end

    it "should be protected against mass assignment" do
      @group = Factory.build(:group)
      @chat_room = Factory.build(:chat_room, :group => @group)
      @another_group = Factory.build(:group)

      @chat_room.attributes = { :group => @another_group }
      @chat_room.group.should be == @group
    end
  end

  describe "#set_redis_access_token_for_user" do
    it "should set access token in Redis" do
      @chat_room = Factory.build(:chat_room, :id => 21)
      @user = Factory.build(:user, :id => 23)
      @generated_token = SecureRandom.hex
      SecureRandom.should_receive(:hex).and_return(@generated_token)
      REDIS.should_receive(:setex).with("chat:21:token:#{@generated_token}", 60, 23)

      @token = @chat_room.set_redis_access_token_for_user(@user)
      @token.should be == @generated_token
      @chat_room.token.should be == @generated_token
    end

    it "should use provided token if present" do
      @chat_room = Factory.build(:chat_room, :id => 21)
      @user = Factory.build(:user, :id => 23)
      SecureRandom.should_not_receive(:hex)
      REDIS.should_receive(:setex).with("chat:21:token:asdfb", 60, 23)

      @token = @chat_room.set_redis_access_token_for_user(@user, "asdfb")
      @token.should be == "asdfb"
      @chat_room.token.should be == "asdfb"
    end
  end
end
