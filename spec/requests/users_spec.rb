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

  scenario "User should be able to edit only his own profile" do
    @billy = FactoryGirl.create(:user, :name => "Billy", :show_email => true, :email => "billy@example.com")
    visit edit_user_path(@billy)
    page.should_not have_content "Edit user"
    visit edit_user_path(@user)
    page.should have_content "Edit user"
  end

  scenario "user should not be able to edit with invalid attributes" do
    visit edit_user_path(@user)
    fill_in :name, :with => ""
    click_button "Update"
    page.should have_content "Edit user"
  end

  scenario "user should be able to edit with valid attributes" do
    visit edit_user_path(@user)
    fill_in :name, :with => "Michael"
    click_button "Update"
    visit user_path(@user)
    page.should have_content "Michael"
    
  end
end
