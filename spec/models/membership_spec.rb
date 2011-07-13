require 'spec_helper'

describe Membership do
  it { should_not allow_value("wrongemail").for(:email) }

  it "should assing user by email before create" do
    user = FactoryGirl.create(:user, :email => "john@doe.com")
    membership = FactoryGirl.create(:membership, :email => "john@doe.com")
    membership.user.should == user
  end

  it "should verify membership" do
    user = FactoryGirl.create(:user, :email => "john@doe.com")
    membership = FactoryGirl.create(:membership, :email => "john@doe.com")
    membership.verify!
    membership.state.should == "active"
  end

  it "should send email with invitation if user not present" do
    membership = FactoryGirl.create(:membership, :email => "nonexisting-joe@doe.com")
    ActionMailer::Base.deliveries.clear
    membership.invite!
    email = ActionMailer::Base.deliveries.last
    email.should_not be_nil
    email.to.should == [membership.email]
    email.encoded.should match(/#{membership.group.name}/)
  end

  it "should send email with group request to founder" do
    user = FactoryGirl.create(:user)
    membership = FactoryGirl.create(:membership, :email => user.email)
    ActionMailer::Base.deliveries.clear
    membership.request!
    email = ActionMailer::Base.deliveries.last
    email.should_not be_nil
    email.to.should == [membership.group.founder.email]
    email.encoded.should match(/#{membership.group.name}/)
  end
end
