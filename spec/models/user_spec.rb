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
  it { should_not allow_value("a" * 41).for(:password) }

  it { should_not allow_mass_assignment_of(:admin) }

  describe "password encryption" do
    it "should have an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end

    it "should set the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end

    describe "has_password? method" do
      it "should be true if the passwords match" do
        @user.has_password?(@user.password).should be_true
      end

      it "should be false if the passwords don't match" do
        @user.has_password?("invalid").should be_false
      end
    end

    describe "authenticate method" do
      it "should return nil on email/password mismatch" do
        wrong_password_user = User.authenticate(@user.email, "wrongpass")
        wrong_password_user.should be_nil
      end

      it "should return nil for an email address with no user" do
        nonexistent_user = User.authenticate("bar@foo.com", @user.password)
        nonexistent_user.should be_nil
      end

      it "should return the user on email/password match" do
        matching_user = User.authenticate(@user.email, @user.password)
        matching_user.should == @user
      end
    end
  end

  describe "remember me" do
    it "should have a remember token" do
      @user.should respond_to(:remember_token)
    end

    it "should have a remember_me! method" do
      @user.should respond_to(:remember_me!)
    end

    it "should set the remember token" do
      @user.remember_me!
      @user.remember_token.should_not be_nil
    end
  end

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

  describe "relationships" do
    before { @followed = FactoryGirl.create(:user) }

    it "should have a relationships method" do
      @user.should respond_to(:relationships)
    end
    it "should have a following method" do
      @user.should respond_to(:following)
    end
    it "should have a follow! method" do
      @user.should respond_to(:follow!)
    end

    it "should follow another user" do
      @user.follow!(@followed)
      @user.should be_following(@followed)
    end

    it "should include the followed user in the following array" do
      @user.follow!(@followed)
      @user.following.should include(@followed)
    end

    it "should have an unfollow! method" do
      @followed.should respond_to(:unfollow!)
    end

    it "should unfollow a user" do
      @user.follow!(@followed)
      @user.unfollow!(@followed)
      @user.should_not be_following(@followed)
    end

    it "should have a reverse_relationships method" do
      @user.should respond_to(:reverse_relationships)
    end

    it "should have a followers method" do
      @user.should respond_to(:followers)
    end

    it "should include the follower in the followers array" do
      @user.follow!(@followed)
      @followed.followers.should include(@user)
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
end
