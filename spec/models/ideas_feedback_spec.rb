require "spec_helper"

describe IdeasFeedback do
  it "should crate a new instance given valid attributes" do
    Factory.build(:ideas_feedback).should be_valid
  end

  describe "user attribute" do
    it "should be required" do
      @feedback = Factory.build(:ideas_feedback, :user => nil)
      @feedback.should_not be_valid
      @feedback.should have(1).error_on(:user)
    end

    it "should be protected agains mass assignment" do
      @user = Factory.build(:user)
      @feedback = Factory.build(:ideas_feedback, :user => @user)
      @another_user = Factory.build(:user)

      @feedback.attributes = { :user => @another_user }
      @feedback.user.should be == @user
    end
  end

  describe "supervision attribute" do
    it "should be required" do
      @feedback = Factory.build(:ideas_feedback, :supervision => nil, :user => Factory.build(:user))
      @feedback.should_not be_valid
      @feedback.should have(1).error_on(:supervision)
    end

    it "should be protected agains mass assignment" do
      @supervision = Factory.build(:supervision)
      @feedback = Factory.build(:ideas_feedback, :supervision => @supervision)
      @another_supervision = Factory.build(:supervision)

      @feedback.attributes = { :supervision => @another_supervision }
      @feedback.supervision.should be == @supervision
    end
  end

  describe "after create" do
    it "should notify supervision with #post_ideas_feedback" do
      @supervision = Factory(:supervision)
      @supervision.should_receive(:post_ideas_feedback)
      @feedback = Factory(:ideas_feedback, :supervision => @supervision)
    end

    it "should publish feedback to Redis channel" do
      @feedback = Factory.build(:ideas_feedback)
      @feedback.should_receive(:publish_to_redis)
      @feedback.save!
    end
  end

  it "should include SupervisionRedisPublisher module" do
    included_modules = IdeasFeedback.send :included_modules
    included_modules.should include(SupervisionRedisPublisher)
  end

  describe "#supervision_publish_attributed" do
    it "should have only known options" do
      @answer = IdeasFeedback.new
      @answer.supervision_publish_attributes.should be == {:only => [:id, :content, :user_id]}
    end
  end
end
