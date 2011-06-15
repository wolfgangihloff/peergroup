require "spec_helper"

feature "Supervision Topic", :js => true do
  def wait_for_connection
    # make sure it's connected and authenticated
    page.should have_css(".supervision.connected")
  end

  background do
    @alice = Factory(:user, :name => "Alice", :email => "alice@example.com")
    @bob = Factory(:user, :name => "Bob", :email => "bob@example.com")

    @group = Factory(:group, :name => "Ruby")
    @group.add_member!(@alice)
    @group.add_member!(@bob)
    @supervision = Factory(:supervision, :group => @group)
  end

  it "should allow to post topic" do
    @alice.join_supervision(@supervision)

    sign_in_interactive(@bob)
    visit new_supervision_membership_path(@supervision)
    click_button "Join session"
    wait_for_connection
    fill_in "topic_content", :with => "Can rails scale?"
    click_button "Post your topic"
    Topic.exists?(:content => "Can rails scale?").should be_true
  end

  it "should display topic posted by other user" do
    @alice.join_supervision(@supervision)
    @bob.join_supervision(@supervision)

    sign_in_interactive(@alice)
    visit supervision_topics_path(@supervision)
    wait_for_connection
    Factory(:topic, :supervision => @supervision, :user => @bob, :content => "Can rails scale?")
    page.should have_content("Can rails scale?")
  end

  it "should allow to vote on topic" do
    @alice.join_supervision(@supervision)
    @bob.join_supervision(@supervision)
    Factory(:topic, :supervision => @supervision, :user => @bob, :content => "Can rails scale?")
    topic = Factory(:topic, :supervision => @supervision, :user => @alice, :content => "What is your favorite color?")
    Factory(:vote, :statement => topic, :user => @alice)

    sign_in_interactive(@bob)
    visit supervision_topics_path(@supervision)
    wait_for_connection
    within "#topic_#{topic.id}" do
      click_button "Vote on this topic"
    end
    @supervision.topic.should == topic
  end
end
