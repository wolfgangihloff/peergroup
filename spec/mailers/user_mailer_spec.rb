require "spec_helper"

describe UserMailer do
  before { ActionMailer::Base.deliveries.clear }

  it "should send group invitation email" do
    membership = FactoryGirl.build(:membership)
    UserMailer.group_invitation(membership).deliver
    ActionMailer::Base.deliveries.should_not be_empty
  end

  it "should send group request email" do
    user = FactoryGirl.create(:user)
    membership = FactoryGirl.build(:membership, :email => user.email, :user => user)
    UserMailer.group_request(membership).deliver
    ActionMailer::Base.deliveries.should_not be_empty
  end
end
