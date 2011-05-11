require "spec_helper"

feature "Groups" do
  background do
    @user = Factory(:user)

    sign_in_interactive(@user)
  end

  scenario "Creating group" do
    visit new_group_path
    fill_in "Name", :with => "Ruby group"
    fill_in "Description", :with => "Developers"
    click_button "Create Group"
    group = Group.where(:name => "Ruby group").first
    group.should_not be_nil
    group.founder.should == @user
  end

  scenario "Deleting group by owner" do
    Factory(:group, :name => "Ruby group", :founder => @user)
    visit groups_path
    page.should have_content("Ruby group")
    within ".group_brief" do
      click_link "delete"
    end
    Group.exists?(:name => "Ruby group").should be_false
  end

  scenario "Joining group" do
    group = Factory(:group, :name => "Ruby group")
    visit groups_path
    within ".group_brief" do
      click_button "join"
    end
    @user.groups.include?(group).should be_true
  end

  scenario "Leaving group" do
    group = Factory(:group, :name => "Ruby group")
    @user.groups << group
    visit groups_path
    within ".group_brief" do
      click_button "leave"
    end
    @user.groups.include?(group).should be_false
  end
end
