require 'spec_helper'

describe User do
  before(:each) do
    @attr = {
      :name => "Example User",
      :email => "user@example.com",
      :password => "foobar",
      :password_confirmation => "foobar"
      }
  end

  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end

  describe "name attribute" do
    it "should require a name" do
      no_name_user = User.new(@attr.merge(:name => ""))
      no_name_user.should_not be_valid
    end

    it "should reject names that are too long" do
      long_name = "a" * 51
      long_name_user = User.new(@attr.merge(:name => long_name))
      long_name_user.should_not be_valid
    end

    it "should be accessible to mass assignment" do
      @user = Factory.build(:user, :name => "Wolfgant")
      @user.attributes = { :name => "Wolf" }
      @user.name.should be == "Wolf"
    end
  end

  describe "email attribute" do
    it "should require an email" do
      no_email_user = User.new(@attr.merge(:email => ""))
      no_email_user.should_not be_valid
    end

    it "should accept valid email addresses" do
      addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
      addresses.each do |address|
        valid_email_user = User.new(@attr.merge(:email => address))
        valid_email_user.should be_valid
      end
    end

    it "should reject invalid email addresses" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
      addresses.each do |address|
        invalid_email_user = User.new(@attr.merge(:email => address))
        invalid_email_user.should_not be_valid
      end
    end

    it "should reject duplicate email addresses" do
      # Put a user with given email address into the database.
      User.create!(@attr)
      user_with_duplicate_email = User.new(@attr)
      user_with_duplicate_email.should_not be_valid
    end

    it "should reject email addresses identical up to case" do
      upcased_email = @attr[:email].upcase
      User.create!(@attr.merge(:email => upcased_email))
      user_with_duplicate_email = User.new(@attr)
      user_with_duplicate_email.should_not be_valid
    end

    it "should be accessible to mass assignment" do
      @user = Factory.build(:user, :email => "wolfgant@example.com")
      @user.attributes = { :email => "wolf@example.com" }
      @user.email.should be == "wolf@example.com"
    end
  end

  describe "password validations" do

    it "should require a password" do
      User.new(@attr.merge(:password => "", :password_confirmation => "")).
        should_not be_valid
    end

    it "should require a matching password confirmation" do
      User.new(@attr.merge(:password_confirmation => "invalid")).
        should_not be_valid
    end

    it "should reject short passwords" do
      short = "a" * 5
      hash = @attr.merge(:password => short, :password_confirmation => short)
      User.new(hash).should_not be_valid
    end

    it "should reject long passwords" do
      long = "a" * 41
      hash = @attr.merge(:password => long, :password_confirmation => long)
      User.new(hash).should_not be_valid
    end
  end

  describe "password encryption" do

    before(:each) do
      @user = User.create!(@attr)
    end

    it "should have an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end

    it "should set the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end

    describe "has_password? method" do

      it "should be true if the passwords match" do
        @user.has_password?(@attr[:password]).should be_true
      end

      it "should be false if the passwords don't match" do
        @user.has_password?("invalid").should be_false
      end
    end

    describe "authenticate method" do

      it "should return nil on email/password mismatch" do
        wrong_password_user = User.authenticate(@attr[:email], "wrongpass")
        wrong_password_user.should be_nil
      end

      it "should return nil for an email address with no user" do
        nonexistent_user = User.authenticate("bar@foo.com", @attr[:password])
        nonexistent_user.should be_nil
      end

      it "should return the user on email/password match" do
        matching_user = User.authenticate(@attr[:email], @attr[:password])
        matching_user.should == @user
      end
    end
  end

  describe "remember me" do

    before(:each) do
      @user = User.create!(@attr)
    end

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

    before(:each) do
      @user = User.create!(@attr)
    end

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

    it "should be protected agains mass assignment" do
      @user.attributes = { :admin => true }
      @user.should_not be_admin
    end
  end

  describe "relationships" do

    before(:each) do
      @user = User.create!(@attr)
      @followed = Factory(:user)
    end

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

  describe "#member_of?" do
    it "should be true for user's groups" do
      @user = Factory(:user)
      @group = Factory(:group)
      @user.groups << @group

      @user.member_of?(@group).should be_true
    end

    it "should not be true for other groups" do
      @user = Factory(:user)
      @group = Factory(:group)

      @user.member_of?(@group).should be_false
    end
  end

  describe "#to_s" do
    it "should return user's name" do
      @user = Factory(:user, :name => "John Smith")

      @user.to_s.should be == @user.name
    end
  end

  describe "#join_supervision" do
    it "should add user to supervision members" do
      @user = Factory(:user)
      @supervision = Factory(:supervision)
      @user.join_supervision(@supervision)
      @supervision.reload
      @supervision.members.should include(@user)
    end
  end
  describe "#leave_supervision" do
    it "should remove user's membership in supervision" do
      @user = Factory(:user)
      @supervision = Factory(:supervision)
      @user.join_supervision(@supervision)
      @user.leave_supervision(@supervision)
      @supervision.reload
      @supervision.members.should_not include(@user)
    end
  end

  describe "#join_group" do
    it "should add user to group members" do
      @user = Factory(:user)
      @group = Factory(:group)
      @user.join_group(@group)
      @group.reload
      @group.members.should include(@user)
      @user.member_of?(@group).should be_true
    end
  end
end
