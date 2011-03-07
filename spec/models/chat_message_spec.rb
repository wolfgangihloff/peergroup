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

  describe "#publish_to_redis" do
    it "should publish itself as JSON to Redis channel" do
      @chat_message = Factory.build(:chat_message, :id => "100", :created_at => Time.now)
      @json_attributes = { :only => [:id, :content, :created_at], :include => { :user => { :only => [:id, :name], :methods => :avatar_url } } }
      @json_representation = @chat_message.to_json(@json_attributes)
      @chat_message.should_receive(:to_json).with(@json_attributes).and_return(@json_representation)
      REDIS.should_receive(:publish).with("chat:#{@chat_message.chat_room.id}", @json_representation)
      @chat_message.publish_to_redis
    end
  end

  describe "after create" do
    it "should publish message to Redis" do
      @chat_message = Factory.build(:chat_message)
      @chat_message.should_receive(:publish_to_redis)
      @chat_message.save!
    end
  end
end
