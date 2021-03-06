require "spec_helper"

feature "Session" do
  scenario "Sign up" do
    visit new_user_registration_path
    fill_in "Name", :with => "John"
    fill_in "Email", :with => "john@doe.com"
    fill_in "Password", :with => "secret"
    fill_in "Passcode", :with => "Pat0ng0"
    click_button "Sign up"
    User.exists?(:name => "John").should be_true
  end
end
