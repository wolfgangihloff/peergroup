require 'spec_helper'

describe User do
  before { @user = FactoryGirl.create(:user) }

  %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp].each do |email|
    it { should allow_value(email).for(:email) }
  end
  %w[user@foo,com user_at_foo.org example.user@foo.].each do |email|
    it { should_not allow_value(email).for(:email) }
  end
  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email).case_insensitive }

  it { should validate_presence_of(:name) }
  it { should_not allow_value("a" * 51).for(:name) }

  it { should validate_presence_of(:password) }
  it { should_not allow_value("1234").for(:password) }

  it { should_not allow_mass_assignment_of(:admin) }


  describe "admin attribute" do
    it "should respond to admin" do
      @user.should respond_to(:admin)
    end

    it "should not be an admin by default" do
      @user.should_not be_admin
    end

    it "should be convertible to an admin" do
      @user.toggle!(:admin)
      @user.should be_admin
    end
  end

  describe "#active_member_of?" do
    it "should be true for user's groups" do
      @group = FactoryGirl.create(:group)
      @group.add_member!(@user)

      @user.active_member_of?(@group).should be_true
    end

    it "should not be true for other groups" do
      @group = FactoryGirl.create(:group)

      @user.active_member_of?(@group).should be_false
    end
  end

  it "should return user's name on to_s method" do
    @user.to_s.should == @user.name
  end

  describe "#join_supervision" do
    it "should add user to supervision members" do
      @supervision = FactoryGirl.create(:supervision)
      @user.join_supervision(@supervision)
      @supervision.reload
      @supervision.members.should include(@user)
    end
  end

  describe "#leave_supervision" do
    it "should remove user's membership in supervision" do
      @supervision = FactoryGirl.create(:supervision)
      @user.join_supervision(@supervision)
      @user.leave_supervision(@supervision)
      @supervision.reload
      @supervision.members.should_not include(@user)
    end
  end

  it "should associate pending group memberships after create" do
    membership = FactoryGirl.create(:membership, :email => "john@doe.com")
    membership.invite!
    user = FactoryGirl.create(:user, :email => "john@doe.com")
    user.invited_memberships.should == [membership]
  end

  it "should not select given user" do
    User.without(@user).should be_empty
  end

  describe "#avatar_url" do
    before do
      @user.email = "john@doe.com"
    end

    it "should be generated" do
      @user.avatar_url.should == "http://www.gravatar.com/avatar/6a6c19fea4a3676970167ce51f39e6ee?size=50&rating=PG&d=identicon"
    end

    it "should be generated with custom options" do
      @user.avatar_url(:size => 30).should == "http://www.gravatar.com/avatar/6a6c19fea4a3676970167ce51f39e6ee?size=30&rating=PG&d=identicon"
    end
  end

  describe "#last_proposed_topic" do
    before do
      @supervision = Factory.create(:supervision)
      Factory.create(:supervision_membership, :supervision => @supervision, :user => @user)
      @supervision.update_attribute(:state, "finished")
    end

    it "should return new topic instance if user did not proposed any topic" do
      @user.last_proposed_topic(@supervision.group).persisted?.should be_false
    end

    it "should return last topic proposition if it was not choosen" do
      @topic = Factory.create(:topic, :supervision => @supervision, :user => @user)
      @supervision.update_attribute(:topic, Factory.create(:topic, :supervision => @supervision, :user => Factory.create(:user) ) )
      @user.last_proposed_topic(@supervision.group).should eq @topic
    end

    it "should return new topic instance if last topic proposition was choosen" do
      @topic = Factory.create(:topic, :supervision => @supervision, :user => @user)
      @supervision.topic = @topic
      @user.last_proposed_topic(@supervision.group).persisted?.should be_false
    end
  end
end
