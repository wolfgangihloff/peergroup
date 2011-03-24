require "spec_helper"

describe "Chat" do
  before do
    Capybara.current_driver = :selenium
    @alice = Factory(:user, :name => "Alice")
    @alice.save!
    @bob = Factory(:user, :name => "Bob")
    @cindy = Factory(:user, :name => "Cindy")
    @designers = Factory(:group, :name => "Designers")
    @designers_chat = @designers.chat_room

    @alice.join_group(@designers)
    @bob.join_group(@designers)
    @cindy.join_group(@designers)

    Factory(:chat_message, :user => @alice, :chat_room => @designers_chat, :content => "Hi @all!")
    Factory(:chat_message, :user => @bob,   :chat_room => @designers_chat, :content => "Hi Alice")
    Factory(:chat_message, :user => @cindy, :chat_room => @designers_chat, :content => "Hello")

    visit "/"
    click_link "Sign in"
    fill_in "Email", :with => @alice.email
    fill_in "Password", :with => @alice.password
    click_button "Sign in"

    #current_path.should be == root_path
    page.should have_content("Welcome Alice")

    click_link "Chat"
    current_path.should be == group_chat_room_path(@designers)
  end

  it "allows to view past messages" do
    page.should have_content("Hi @all")
    page.should have_content("Hi Alice")
    page.should have_content("Hello")
  end

  it "allows to post new message", :js => true do
    page.should have_css(".chat_room.connected")
    Factory(:user, :name => "test")
    fill_in "chat_message_content", :with => "What's up?"
    click_button "Submit"

    page.should have_content("What's up?")
  end

  it "allows to view other's messages in real-time", :js => true do
    page.should have_css(".chat_room.connected")
    Factory(:chat_message, :user => @bob, :chat_room => @designers_chat, :content => "What's up?")

    page.should have_content("What's up?")
  end
end
