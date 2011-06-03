require 'spec_helper'

describe Group do
  before { @group = Factory(:group) }

  [:name, :description, :founder].each do |attribute|
    it { should validate_presence_of(attribute) }
  end
  it { should_not allow_mass_assignment_of(:founder_id) }

  it { should validate_uniqueness_of(:name) }
  it { should_not allow_value("a" * 256).for(:name) }
  it { should_not allow_value("a" * 256).for(:description) }

  describe "#current_supervision" do
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

  describe "#to_s" do
    it "should return group's name" do
      group = Factory.build(:group, :name => "Group name")

      group.to_s.should be == group.name
    end
  end

  describe "#add_member!" do
    it "should add user to group's members" do
      group = Factory(:group)
      user = Factory(:user)

      group.members.should_not include(user)

      group.add_member!(user)
      group.reload.members.should include(user)
    end
  end

  describe "after_create" do
    it "should add group founder as member" do
      user = Factory(:user)
      group = Factory(:group, :founder => user)
      group.members.should include(user)
    end

    it "should create chat room for group" do
      group = Factory(:group)
      group.chat_room.should_not be_nil
    end
  end
end
