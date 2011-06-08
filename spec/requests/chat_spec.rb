require "spec_helper"

feature "Chat" do
  background do
    @alice = Factory(:user, :name => "Alice")
    @bob = Factory(:user, :name => "Bob")
    @cindy = Factory(:user, :name => "Cindy")
    @designers = Factory(:group, :name => "Designers")
    @designers_chat = @designers.chat_room

    @designers.add_member!(@alice)
    @designers.add_member!(@bob)
    @designers.add_member!(@cindy)

    Factory(:chat_message, :user => @alice, :chat_room => @designers_chat, :content => "Hi @all!")
    Factory(:chat_message, :user => @bob,   :chat_room => @designers_chat, :content => "Hi Alice")
    Factory(:chat_message, :user => @cindy, :chat_room => @designers_chat, :content => "Hello")

    sign_in_interactive(@alice)
    click_link "Chat"
  end

  scenario "allows to view past messages" do
    page.should have_content("Hi @all")
    page.should have_content("Hi Alice")
    page.should have_content("Hello")
  end

  scenario "allows to post new message", :js => true do
    page.should have_css(".chat_room.connected")
    Factory(:user, :name => "test")
    fill_in "chat_message_content", :with => "What's up?"
    click_button ">>"

    page.should have_content("What's up?")
  end

  scenario "allows to view other's messages in real-time", :js => true do
    page.should have_css(".chat_room.connected")
    Factory(:chat_message, :user => @bob, :chat_room => @designers_chat, :content => "What's up?")

    page.should have_content("What's up?")
  end
end
