require "spec_helper"

feature "Chat" do
  background do
    @alice = FactoryGirl.create(:user, :name => "Alice")
    @bob = FactoryGirl.create(:user, :name => "Bob")
    @cindy = FactoryGirl.create(:user, :name => "Cindy")
    @designers = FactoryGirl.create(:group, :name => "Designers")
    @designers_chat = @designers.chat_room

    @designers.add_member!(@alice)
    @designers.add_member!(@bob)
    @designers.add_member!(@cindy)

    FactoryGirl.create(:chat_message, :user => @alice, :chat_room => @designers_chat, :content => "Hi @all!")
    FactoryGirl.create(:chat_message, :user => @bob,   :chat_room => @designers_chat, :content => "Hi Alice")
    FactoryGirl.create(:chat_message, :user => @cindy, :chat_room => @designers_chat, :content => "Hello")

    sign_in_interactive(@alice)
    visit group_path @designers
  end

  scenario "allows to view past messages" do
    page.should have_content("Hi @all")
    page.should have_content("Hi Alice")
    page.should have_content("Hello")
  end

  scenario "allows to post new message", :js => true do
    page.should have_css(".chat_room.connected")
    FactoryGirl.create(:user, :name => "test")
    fill_in "chat_message_content", :with => "What's up?"
    click_button ">>"

    page.should have_content("What's up?")
  end

  scenario "allows to view other's messages in real-time", :js => true do
    page.should have_css(".chat_room.connected")
    FactoryGirl.create(:chat_message, :user => @bob, :chat_room => @designers_chat, :content => "What's up?")

    page.should have_content("What's up?")
  end
end
