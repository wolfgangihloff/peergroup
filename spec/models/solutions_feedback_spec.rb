require "spec_helper"

describe SolutionsFeedback do
  [:user, :supervision, :content].each do |attribute|
    it { should validate_presence_of(attribute) }
  end
  [:user_id, :supervision_id].each do |attribute|
    it { should_not allow_mass_assignment_of(attribute) }
  end

  describe "after create" do
    it "should notify supervision with #post_solutions_feedback" do
      @supervision = FactoryGirl.create(:supervision)
      @supervision.should_receive(:post_solutions_feedback)
      @feedback = FactoryGirl.create(:solutions_feedback, :supervision => @supervision)
    end

    it "should publish feedback to Redis channel" do
      @feedback = FactoryGirl.build(:solutions_feedback)
      @feedback.should_receive(:publish_to_redis)
      @feedback.save!
    end
  end

  it "should include SupervisionRedisPublisher module" do
    SolutionsFeedback.new.should respond_to(:publish_to_redis)
  end

  describe "#supervision_publish_attributed" do
    it "should have only known options" do
      @answer = SolutionsFeedback.new
      @answer.supervision_publish_attributes.should == {:only => [:id, :content, :user_id]}
    end
  end
end
