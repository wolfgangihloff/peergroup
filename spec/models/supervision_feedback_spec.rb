require "spec_helper"

describe SupervisionFeedback do
  [:user, :supervision, :content].each do |attribute|
    it { should validate_presence_of(attribute) }
  end
  [:user_id, :supervision_id].each do |attribute|
    it { should_not allow_mass_assignment_of(attribute) }
  end

  describe "after create" do
    it "should notify supervision with #post_supervision_feedback" do
      @supervision = Factory(:supervision)
      @supervision.should_receive(:post_supervision_feedback)
      @feedback = Factory(:supervision_feedback, :supervision => @supervision)
    end

    it "should publish feedback to Redis channel" do
      @feedback = Factory.build(:supervision_feedback)
      @feedback.should_receive(:publish_to_redis)
      @feedback.save!
    end
  end

  it "should include SupervisionRedisPublisher module" do
    SupervisionFeedback.new.should respond_to(:publish_to_redis)
  end

  describe "#supervision_publish_attributed" do
    it "should have only known options" do
      @answer = SupervisionFeedback.new
      @answer.supervision_publish_attributes.should == {:only => [:id, :content, :user_id]}
    end
  end
end
