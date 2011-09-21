require "spec_helper"

feature "Supervision membership" do
  background do
    @group = FactoryGirl.create(:group, :name => "Ruby group")
    @user = FactoryGirl.create(:user, :name => "John")

    @group.add_member!(@user)
  end

  scenario "Creating new session", :js => true do
    sign_in_interactive(@user)
    visit group_path(@group)

    click_link "New supervision"
    page.should have_content("Supervision Session")
    sleep(5)
    @group.supervisions.should_not be_empty
  end

  scenario "Joining existing session", :js => true do
    sleep(2)
    sign_in_interactive(@user)
    @group.supervisions.create!
    visit group_path(@group)
    sleep(2)
    click_link "join"
    page.should have_content("Supervision Session")
  end
end
