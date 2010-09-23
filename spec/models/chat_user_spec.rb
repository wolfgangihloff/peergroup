require 'spec_helper'

describe ChatUser do
  it "should create a new instance given valid attributes" do
    Factory(:chat_user)
  end

  describe "active?" do
    before do
      @chat_user = Factory(:chat_user)
      @user = @chat_user.user
      @chat_room = @chat_user.chat_room
    end

    it "should admit when user wrote something within 3 seconds" do
      past_chat_update(:chat_room_id => @chat_room.id, :user_id => @user.id,
        :message_updated_at => 2.seconds.ago)
      @chat_user.active?.should be_true
    end

    it "should deny when user wrote something earlier then 3 seconds ago" do
      past_chat_update(:chat_room_id => @chat_room.id, :user_id => @user.id,
        :message_updated_at => 4.seconds.ago)
      @chat_user.active?.should be_false
    end
  end
end

