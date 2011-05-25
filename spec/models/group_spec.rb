require 'spec_helper'

describe Group do
  it "should create a new instance given valid attributes" do
    Factory(:group)
  end

  describe "#current_supervision" do
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

  describe "#to_s" do
    it "should return group's name" do
      group = Factory.build(:group, :name => "Group name")

      group.to_s.should be == group.name
    end
  end

  describe "name attribute" do
    it "should be required" do
      group = Factory.build(:group, :name => nil)

      group.should_not be_valid
      group.should have(1).error_on(:name)
    end

    it "should be unique" do
      other_group = Factory(:group, :name => "group")
      group = Factory.build(:group, :name => "group")

      group.should_not be_valid
      group.should have(1).error_on(:name)
    end

    it "should be limited in length" do
      group = Factory.build(:group)
      group.name = "a" * 256
      group.should_not be_valid
      group.should have(1).error_on(:name)

      group.name = "a" * 255
      group.should be_valid
      group.should have(:no).errors_on(:name)
    end

    it "should be accessible to mass_assignment" do
      group = Factory.build(:group, :name => "A Group")
      group.attributes = {:name => "A Team"}
      group.name.should be == "A Team"
    end
  end

  describe "description attribute" do
    it "should be required" do
      group = Factory.build(:group, :description => nil)

      group.should_not be_valid
      group.should have(1).error_on(:description)
    end

    it "should be limited in length" do
      group = Factory.build(:group)
      group.description = "a" * 256
      group.should_not be_valid
      group.should have(1).error_on(:description)

      group.description = "a" * 255
      group.should be_valid
      group.should have(:no).errors_on(:description)
    end

    it "should be accessible to mass_assignment" do
      group = Factory.build(:group, :description => "A Group")
      group.attributes = {:description => "A Team"}
      group.description.should be == "A Team"
    end
  end

  describe "#add_member!" do
    it "should add user to group's members" do
      group = Factory(:group)
      user = Factory(:user)

      group.members.should_not include(user)

      group.add_member!(user)
      group.members.should include(user)
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

  describe "founder attribute" do
    it "should be required" do
      group = Factory.build(:group, :founder => nil)
      group.should_not be_valid
      group.should have(1).error_on(:founder)
    end

    it "should be protected against mass_assignment" do
      founder = Factory.build(:user)
      group = Factory.build(:group, :founder => founder)
      user = Factory.build(:user)
      group.attributes = {:founder => user}
      group.founder.should be == founder
    end
  end
end
