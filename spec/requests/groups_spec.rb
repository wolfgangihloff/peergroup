require "spec_helper"

feature "Groups" do
  background do
    @user = Factory(:user)
    Factory(:group, :name => "Ruby group", :founder => @user)

    sign_in_interactive(@user)
  end

  scenario "deleting group by owner" do
    visit groups_path
    page.should have_content("Ruby group")
    within ".group_brief" do
      click_link "delete"
    end
    Group.exists?(:name => "Ruby group").should be_false
  end
end
