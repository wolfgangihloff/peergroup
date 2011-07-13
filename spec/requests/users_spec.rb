require "spec_helper"

feature "Users" do
  background do
    @user = FactoryGirl.create(:user, :name => "John")

    sign_in_interactive(@user)
  end

  scenario "Listing users" do
    FactoryGirl.create(:user, :name => "Billy")
    visit "/users"
    page.should have_content("John")
    page.should have_content("Billy")
  end
end
