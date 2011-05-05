require "spec_helper"
# TODO: rewrite to capybara steak dsl

describe "Chat", :js => true do
  before do
    @alice = Factory(:user, :name => "Alice")
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
  end

  context "specs" do
    before do
      sign_in_interactive(@alice)
      click_link "Chat"
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
end
