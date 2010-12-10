require 'spec_helper'

describe Group do
  it "should create a new instance given valid attributes" do
    Factory(:group)
  end

  describe "current_supervision" do
    before { @group = Factory(:group) }

    it "should return first unfinished supervision" do
      supervision = @group.supervisions.create!
      @group.current_supervision.should == supervision
    end

    it "should return nil when no unfinished supervisions" do
      @group.supervisions.create! do |supervision|
        supervision.state = "finished"
      end
      @group.current_supervision.should be_nil
    end
  end
end
