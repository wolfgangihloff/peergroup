require "spec_helper"

describe UserMailer do
  before { ActionMailer::Base.deliveries.clear }

  it "should send group invitation email" do
    membership = Factory.build(:membership)
    UserMailer.group_invitation(membership).deliver
    ActionMailer::Base.deliveries.should_not be_empty
  end

  it "should send group request email" do
    user = Factory(:user)
    membership = Factory.build(:membership, :email => user.email, :user => user)
    UserMailer.group_request(membership).deliver
    ActionMailer::Base.deliveries.should_not be_empty
  end
end
