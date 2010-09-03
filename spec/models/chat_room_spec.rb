require 'spec_helper'

describe ChatRoom do

  it "should create a new instance given valid attributes" do
    Factory(:chat_room)
  end

  describe "chat_updates method" do
    before do
      @chat_room = Factory(:chat_room)
      @chat_updates = Array.new(5) { Factory(:chat_update, :chat_room_id => @chat_room.id) }
      @invalid_update = Factory(:chat_update)
      @query = @chat_room.chat_updates
    end

    it "should return the query" do
      @query.is_a?(Plucky::Query).should be_true
    end

    it "should include only chat updates belonging to the room" do
      @query.all.should =~ @chat_updates
    end

    it "should not include chat updates from other rooms" do
      @query.all.should_not include(@invalid_update)
    end
  end
end
