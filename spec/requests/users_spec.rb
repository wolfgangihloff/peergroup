require "spec_helper"

feature "Users" do
  background do
    @user = Factory(:user, :name => "John")

    sign_in_interactive(@user)
  end

  scenario "Listing users" do
    Factory(:user, :name => "Billy")
    visit "/users"
    page.should have_content("John")
    page.should have_content("Billy")
  end
end
