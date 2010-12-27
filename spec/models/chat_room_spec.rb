require "spec_helper"

describe ChatRoom do
  describe "group attribute" do
    it "should be required" do
      @chat_room = Factory.build(:chat_room, :group => nil)
      @chat_room.valid?.should be_false
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
end
