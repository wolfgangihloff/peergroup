require "spec_helper"

feature "Groups" do
  background do
    @user = FactoryGirl.create(:user)

    sign_in_interactive(@user)
  end

  scenario "Browsing groups" do
    FactoryGirl.create(:group, :name => "Ruby group", :founder => @user)
    FactoryGirl.create(:group, :name => "PHP group")
    visit "/"
    click_link "Groups"
    page.should have_content("Ruby group")
    page.should have_content("PHP group")
  end

  scenario "Creating group" do
    visit new_founder_group_path
    fill_in "Name", :with => "Ruby group"
    fill_in "Description", :with => "Developers"
    click_button "Create Group"
    group = Group.where(:name => "Ruby group").first
    group.should_not be_nil
    group.founder.should == @user
  end

  scenario "Joining group" do
    group = FactoryGirl.create(:group, :name => "Ruby group")
    visit groups_path
    within ".group_brief" do
      click_button "join"
    end
    @user.active_groups.include?(group).should be_true
  end

  scenario "Leaving group" do
    group = FactoryGirl.create(:group, :name => "Ruby group")
    group.add_member!(@user)
    visit groups_path
    within ".group_brief" do
      click_button "leave"
    end
    @user.groups.include?(group).should be_false
  end

  scenario "Group founder shouldn't be able to leave group" do
    group = FactoryGirl.create(:group, :name => "Ruby group", :founder => @user)
    visit groups_path
    within ".group_brief" do
      page.should_not have_content("leave")
    end
  end

  scenario "Display notification to user if supervision session got stared" do
    Capybara.current_driver = :selenium
    @alice = FactoryGirl.create(:user, :name => "Alice", :email => "alice@example.com")
    @bob = FactoryGirl.create(:user, :name => "Bob", :email => "bob@example.com")

    @group = FactoryGirl.create(:group, :name => "FuFighters")
    @group.add_member!(@alice)
    @group.add_member!(@bob)

    Capybara.using_session :bob do
      sign_in_interactive(@bob)
      visit group_path(@group)
      sleep(3)
    end

    Capybara.using_session :alice do
      sign_in_interactive(@alice)
      visit group_path(@group)
      sleep(3)
    end

    Capybara.using_session :bob do
      click_link "New supervision"
      click_button "Yes"
    end

    Capybara.using_session :alice do
      page.should have_flash("New supervision started join")
      within(".flash-messages .flash") do
        click_link "join"
      end
      page.should have_content("Join session")
    end
  end

  scenario "Display requested membership to group founder" do
    @bob = FactoryGirl.create(:user, :name => "Bob", :email => "bob@example.com")

    @group = FactoryGirl.create(:group, :name => "FuFighters", :founder => @user, :closed => true)
    @membership = @group.memberships.build(:email => @bob.email)
    @membership.save!
    @membership.request!
    visit group_path(@group)
    page.should have_content("There is 1 requested membership. Manage")
  end
end
