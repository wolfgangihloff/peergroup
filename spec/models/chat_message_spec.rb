require "spec_helper"

describe ChatMessage do
  describe "user attribute" do
    it "should be required" do
      @chat_message = Factory.build(:chat_message, :user => nil)
      @chat_message.should_not be_valid
      @chat_message.should have(1).error_on(:user)
    end

    it "should be protected agains mass assignment" do
      @user = Factory.build(:user)
      @chat_message = Factory.build(:chat_message, :user => @user)
      @another_user = Factory.build(:user)

      @chat_message.attributes = { :user => @another_user }
      @chat_message.user.should be == @user
    end
  end

  describe "chat_room attribute" do
    it "should be required" do
      @chat_message = Factory.build(:chat_message, :chat_room => nil)
      @chat_message.should_not be_valid
      @chat_message.should have(1).error_on(:chat_room)
    end

    it "should be protected agains mass assignment" do
      @chat_room = Factory.build(:chat_room)
      @chat_message = Factory.build(:chat_message, :chat_room => @chat_room)
      @another_chat_room = Factory.build(:chat_room)

      @chat_message.attributes = { :chat_room => @another_chat_room }
      @chat_message.chat_room.should be == @chat_room
    end
  end

  describe "content attribute" do
    it "should be required" do
      @chat_message = Factory.build(:chat_message, :content => nil)
      @chat_message.should_not be_valid
      @chat_message.should have(1).error_on(:content)
    end

    it "should be accessible to mass assignemt" do
      @chat_message = Factory.build(:chat_message, :content => "Content")
      @chat_message.attributes = { :content => "New content" }
      @chat_message.content.should be == "New content"
    end
  end

  describe "after create" do
    it "should publish message to Redis" do
      # id and created_at are set to workaround problem with setting them after save
      # but we need to know them to stub method on REDIS
      @chat_message = Factory.build(:chat_message, :id => "100", :created_at => Time.now)
      REDIS.should_receive(:publish).with("chat:#{@chat_message.chat_room.id}:message",
                                          "#{@chat_message.user.id}:#{@chat_message.created_at.to_i}:#{@chat_message.id}:#{@chat_message.content}")
      @chat_message.save!
    end
  end
end
