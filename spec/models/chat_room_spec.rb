require "spec_helper"

describe ChatRoom do
  it { should validate_presence_of(:group) }
  [:group_id, :supervision_id, :leader_id, :problem_owner_id].each do |attribute|
    it { should_not allow_mass_assignment_of(attribute) }
  end

  describe "#set_redis_access_token_for_user" do
    it "should set access token in Redis" do
      @chat_room = FactoryGirl.build(:chat_room, :id => 21)
      @user = FactoryGirl.build(:user, :id => 23)
      @generated_token = SecureRandom.hex
      SecureRandom.should_receive(:hex).and_return(@generated_token)
      REDIS.should_receive(:setex).with("chat:21:token:#{@generated_token}", 60, 23)

      @token = @chat_room.set_redis_access_token_for_user(@user)
      @token.should be == @generated_token
      @chat_room.token.should be == @generated_token
    end

    it "should use provided token if present" do
      @chat_room = FactoryGirl.build(:chat_room, :id => 21)
      @user = FactoryGirl.build(:user, :id => 23)
      SecureRandom.should_not_receive(:hex)
      REDIS.should_receive(:setex).with("chat:21:token:asdfb", 60, 23)

      @token = @chat_room.set_redis_access_token_for_user(@user, "asdfb")
      @token.should be == "asdfb"
      @chat_room.token.should be == "asdfb"
    end
  end
end
