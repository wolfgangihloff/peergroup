require "spec_helper"

feature "Group membership requests" do
  background do
    @founder = Factory(:user)
    @group = Factory(:group, :invitable => true, :founder => @founder)
  end

  scenario "Requesting membership" do
    user = Factory(:user)
    sign_in_interactive(user)
    visit all_groups_path
    within ".group_brief" do
      click_button "request membership"
    end
    @group.requested_members.exists?(user).should be_true
  end

  scenario "Accepting request membership by owner" do
    user = Factory(:user, :email => "billy@kid.com")
    @group.memberships.create!(:email => "billy@kid.com").request!

    sign_in_interactive(@founder)
    visit group_path(@group)
    click_button "accept"
    @group.active_members.exists?(user).should be_true
  end

  scenario "Rejecting request membership by owner" do
    user = Factory(:user, :email => "billy@kid.com")
    @group.memberships.create!(:email => "billy@kid.com").request!

    sign_in_interactive(@founder)
    visit group_path(@group)
    click_button "reject"
    @group.members.should_not include(user)
  end
end
