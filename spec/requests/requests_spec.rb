require "spec_helper"

feature "Group membership requests" do
  background do
    @founder = FactoryGirl.create(:user)
    @group = FactoryGirl.create(:group, :closed => true, :founder => @founder)
  end

  scenario "Requesting membership" do
    user = FactoryGirl.create(:user)
    sign_in_interactive(user)
    visit groups_path
    within ".group_brief" do
      click_button "request membership"
    end
    @group.requested_members.exists?(user).should be_true
  end

  scenario "Accepting request membership by owner" do
    user = FactoryGirl.create(:user, :email => "billy@kid.com")
    @group.memberships.create!(:email => "billy@kid.com").request!

    sign_in_interactive(@founder)
    visit edit_founder_group_path(@group)
    click_button "Accept"
    @group.active_members.exists?(user).should be_true
  end

  scenario "Rejecting request membership by owner" do
    user = FactoryGirl.create(:user, :email => "billy@kid.com")
    @group.memberships.create!(:email => "billy@kid.com").request!

    sign_in_interactive(@founder)
    visit edit_founder_group_path(@group)
    click_button "Reject"
    @group.members.should_not include(user)
  end
end
