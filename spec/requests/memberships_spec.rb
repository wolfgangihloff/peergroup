require "spec_helper"

feature "Memberships" do
  background do
    @founder = FactoryGirl.create(:user)
    @group = FactoryGirl.create(:group, :closed => true, :founder => @founder)
  end

  scenario "Removing member from group by owner" do
    user = FactoryGirl.create(:user, :email => "billy@kid.com")
    @group.memberships.create!(:email => "billy@kid.com").verify!

    sign_in_interactive(@founder)
    visit group_path(@group)
    click_button "remove from group"
    @group.memberships.exists?(:email => "billy@kid.com").should be_false
  end
end
