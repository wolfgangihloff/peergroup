require 'spec_helper'

describe Group do
  before { @group = FactoryGirl.create(:group) }

  [:name, :founder].each do |attribute|
    it { should validate_presence_of(attribute) }
  end
  it { should_not allow_mass_assignment_of(:founder_id) }

  it { should validate_uniqueness_of(:name) }
  it { should_not allow_value("a" * 256).for(:name) }
  it { should_not allow_value("a" * 256).for(:description) }

  describe "current supervision" do
    it "should return first unfinished supervision" do
      supervision = @group.supervisions.create!
      @group.supervisions.current.should == supervision
    end

    it "should return nil when no unfinished supervisions" do
      @group.supervisions.create! do |supervision|
        supervision.state = "finished"
      end
      @group.supervisions.current.should be_nil
    end
  end

  describe "#to_s" do
    it "should return group's name" do
      group = FactoryGirl.build(:group, :name => "Group name")

      group.to_s.should be == group.name
    end
  end

  describe "#add_member!" do
    it "should add user to group's members" do
      group = FactoryGirl.create(:group)
      user = FactoryGirl.create(:user)

      group.members.should_not include(user)

      group.add_member!(user)
      group.reload.members.should include(user)
    end
  end

  describe "after_create" do
    it "should add group founder as member" do
      user = FactoryGirl.create(:user)
      group = FactoryGirl.create(:group, :founder => user)
      group.members.should include(user)
    end

    it "should create chat room for group" do
      group = FactoryGirl.create(:group)
      group.chat_room.should_not be_nil
    end
  end

  it "should accept membership requests after opening group" do
    @group.update_attributes!(:closed => true)
    membership = FactoryGirl.create(:membership, :group => @group, :user => FactoryGirl.create(:user))
    membership.request!
    @group.update_attributes(:closed => false)
    @group.active_memberships.should include(membership)
  end

  it "should check if given user is founder" do
    @group.founded_by?(@group.founder).should be_true
    @group.founded_by?(Factory.build(:user)).should be_false
  end
end
