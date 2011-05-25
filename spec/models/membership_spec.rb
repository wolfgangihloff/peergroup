require 'spec_helper'

describe Membership do
  it { should_not allow_value("wrongemail").for(:email) }

  it "should assing user by email before create" do
    user = Factory(:user, :email => "john@doe.com")
    membership = Factory(:membership, :email => "john@doe.com")
    membership.user.should == user
  end

  it "should verify membership" do
    user = Factory(:user, :email => "john@doe.com")
    membership = Factory(:membership, :email => "john@doe.com")
    membership.verify!
    membership.state.should == "active"
  end
end
