require "spec_helper"

feature "Supervision membership" do
  background do
    @group = FactoryGirl.create(:group, :name => "Ruby group")
    @user = FactoryGirl.create(:user, :name => "John")

    @group.add_member!(@user)

    sign_in_interactive(@user)
  end

  scenario "Creating new session", :js => true do
    visit group_path(@group)

    click_link "New supervision"
    page.should have_content("Do you want to create new Supervision Session?")
    click_button "Create Supervision"
    @group.supervisions.should_not be_empty
  end

  scenario "Joining existing session", :js => true do
    @group.supervisions.create!
    visit group_path(@group)
    click_link "join"
    page.should have_content("Supervision Session")
  end
end
