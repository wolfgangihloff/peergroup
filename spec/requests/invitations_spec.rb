require "spec_helper"

feature "Invitations" do
  background do
    @founder = Factory(:user)
    @group = Factory(:group, :invitable => true, :founder => @founder)
  end

  scenario "Sending invitation" do
    sign_in_interactive(@founder)
    visit groups_path
    within ".group_brief" do
      click_link "Invitations"
    end
    fill_in "Email", :with => "billy@kid.com"
    click_button "Invite"
    @group.invited_memberships.exists?(:email => "billy@kid.com").should be_true
  end

  scenario "Accepting invitation" do
    user = Factory(:user, :email => "billy@kid.com")
    @group.memberships.create!(:email => "billy@kid.com")

    sign_in_interactive(user)
    visit groups_path
    within ".group_brief" do
      click_button "accept"
    end
    @group.active_members.should include(user)
  end

  scenario "Rejecting invitation" do
    user = Factory(:user, :email => "billy@kid.com")
    @group.memberships.create!(:email => "billy@kid.com")

    sign_in_interactive(user)
    visit groups_path
    within ".group_brief" do
      click_button "reject"
    end
    @group.members.should_not include(user)
  end
end
