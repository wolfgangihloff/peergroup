require "spec_helper"

describe ChatMessage do
  [:user, :chat_room, :content].each do |attribute|
    it { should validate_presence_of(attribute) }
  end
  [:user_id, :chat_room_id].each do |attribute|
    it { should_not allow_mass_assignment_of(attribute) }
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
