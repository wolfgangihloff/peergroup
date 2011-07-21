require 'spec_helper'

describe SupervisionMembership do
  before do
    @group = FactoryGirl.create(:group)
    @user = FactoryGirl.create(:user)
    @group.add_member!(@user)
  end

  it "should not allow to join to cancelled supervision" do
    supervision = FactoryGirl.create(:supervision, :group => @group, :state => "cancelled")
    membership = supervision.memberships.build(:user => @user)
    membership.should_not be_valid
    membership.errors[:supervision].should_not be_nil
  end

  it "should not allow to join to finished supervision" do
    supervision = FactoryGirl.create(:supervision, :group => @group, :state => "finished")
    membership = supervision.memberships.build(:user => @user)
    membership.should_not be_valid
    membership.errors[:supervision].should_not be_nil
  end
end
