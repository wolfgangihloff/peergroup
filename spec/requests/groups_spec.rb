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
    visit group_path(group)
    click_button "leave group"
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
      sleep(5)
    end

    Capybara.using_session :bob do
      click_link "New supervision"
      click_button "Create Supervision"
    end

    Capybara.using_session :alice do
      wait_until do
        page.should have_flash("New supervision started join")
      end
      within(".flash-messages .flash") do
        click_link "join"
      end
      page.should have_content("Supervision Session")
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

  scenario "Display link to active supervision" do
    @group = FactoryGirl.create(:group, :name => "FuFighters")

    visit group_path(@group)
    page.should_not have_content("Supervision active, join")

    @bob = FactoryGirl.create(:user, :name => "Bob", :email => "bob@example.com")
    @supervision = FactoryGirl.create(:supervision, :group => @group)
    @bob.join_supervision(@supervision)

    visit group_path(@group)
    page.should have_content("Supervision active, join")
  end

  scenario "Display supervisions history" do
    @group = FactoryGirl.create(:group, :name => "FuFighters")
    visit group_path(@group)
    page.should_not have_content("History")

    FactoryGirl.create(:supervision, :group => @group, :state => "finished", :topic => FactoryGirl.create(:topic, :user => @user))

    visit group_path(@group)
    page.should have_content("History")
  end

  scenario "Display propper buttons on groups page" do
    @my_group_without_supervision = FactoryGirl.create(:group, :name => "Ruby Group", :founder => @user)
    @my_group_with_supervision = FactoryGirl.create(:group, :name => "Scala Group", :founder => @user)
    FactoryGirl.create(:supervision, :group => @my_group_with_supervision)

    @closed_group_without_request = FactoryGirl.create(:group, :name => "Confidential Group", :closed => true)
    @closed_group_with_request = FactoryGirl.create(:group, :name => "Strictly Confidential Group", :closed => true)
    @membership = @closed_group_with_request.memberships.build(:email => @user.email)
    @membership.save!
    @membership.request!

    @open_group_without_supervision = FactoryGirl.create(:group, :name => "Active Group")
    @open_group_with_supervision = FactoryGirl.create(:group, :name => "PHP Group")
    FactoryGirl.create(:supervision, :group => @open_group_with_supervision)

    visit groups_path

    within "#group_#{@my_group_without_supervision.id} .actions" do
      page.should_not have_selector "li"
    end

    within "#group_#{@my_group_with_supervision.id} .actions li" do
       page.should have_content "Join active supervision"
    end

    within "#group_#{@closed_group_without_request.id}" do
      page.should have_button "request membership"
    end

    within "#group_#{@closed_group_with_request.id}" do
      page.should have_content "Awaiting group owner acceptance"
    end

    within "#group_#{@open_group_with_supervision.id}" do
      page.should have_button "join"
    end

    within "#group_#{@open_group_with_supervision.id}" do
      page.should have_button "join"
    end
 
  end
end
