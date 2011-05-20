require "spec_helper"

feature "Static pages" do
  scenario "Help" do
    visit "/help"
    page.should have_content("This software will be released as part of Patongo!")
  end

  scenario "About" do
    visit "/about"
    page.should have_content("About Peer Supervision Groups")
  end

  scenario "Contact" do
    visit "/contact"
    page.should have_content("wolfgang.ihloff@gmail.com")
  end
end
