require "spec_helper"

feature "Users" do
  background do
    @user = FactoryGirl.create(:user, :name => "John")

    sign_in_interactive(@user)
  end

  scenario "In public profile page email should be visible only if user checked show_email field" do
    @billy = FactoryGirl.create(:user, :name => "Billy", :show_email => true, :email => "billy@example.com")
    @bob = FactoryGirl.create(:user, :name => "Billy", :show_email => false, :email => "bob@example.com")
    visit user_path(@billy)
    page.should have_content "billy@example.com"
    visit user_path(@bob)
    page.should_not have_content "bob@example.com"
  end

  scenario "Should display private profile page for current user" do
    visit user_path(@user)
    page.should have_content "Hi John"
    page.should have_content "Change Your gravatar image"
  end
end
