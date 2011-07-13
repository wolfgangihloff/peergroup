require "spec_helper"

feature "Supervision membership" do
  background do
    @group = FactoryGirl.create(:group, :name => "Ruby group")
    @user = FactoryGirl.create(:user, :name => "John")

    @group.add_member!(@user)

    sign_in_interactive(@user)
  end

  scenario "Creating new session" do
    visit "/"
    within ".group_brief" do
      click_link "Session"
    end
    page.should have_content("Do you want to create new Supervision Session?")
    click_button "Yes"
    @group.supervisions.should_not be_empty
  end

  scenario "Joining existing session" do
    @group.supervisions.create!
    visit "/"
    within ".group_brief" do
      click_link "Session"
    end
    click_button "Join session"
    page.should have_content("Supervision Session")
  end
end
