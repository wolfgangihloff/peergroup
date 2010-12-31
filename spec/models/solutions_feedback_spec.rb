require "spec_helper"

describe SolutionsFeedback do
  it "should crate a new instance given valid attributes" do
    Factory.build(:solutions_feedback).valid?.should be_true
  end

  describe "user attribute" do
    it "should be required" do
      @feedback = Factory.build(:solutions_feedback, :user => nil)
      @feedback.valid?.should be_false
      @feedback.should have(1).error_on(:user)
    end

    it "should be protected agains mass assignment" do
      @user = Factory.build(:user)
      @feedback = Factory.build(:solutions_feedback, :user => @user)
      @another_user = Factory.build(:user)

      @feedback.attributes = { :user => @another_user }
      @feedback.user.should be == @user
    end
  end

  describe "supervision attribute" do
    it "should be required" do
      @feedback = Factory.build(:solutions_feedback, :supervision => nil, :user => Factory.build(:user))
      @feedback.valid?.should be_false
      @feedback.should have(1).error_on(:supervision)
    end

    it "should be protected agains mass assignment" do
      @supervision = Factory.build(:supervision)
      @feedback = Factory.build(:solutions_feedback, :supervision => @supervision)
      @another_supervision = Factory.build(:supervision)

      @feedback.attributes = { :supervision => @another_supervision }
      @feedback.supervision.should be == @supervision
    end
  end

  describe "after create" do
    it "should notify supervision with #post_solutions_feedback" do
      @supervision = Factory(:supervision)
      @feedback = Factory.build(:solutions_feedback, :supervision => @supervision)
      @supervision.should_receive(:post_solutions_feedback).with(@feedback)
      @feedback.save!
    end
  end
end
