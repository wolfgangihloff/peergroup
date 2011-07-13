require "spec_helper"

describe Question do
  [:user, :supervision, :content].each do |attribute|
    it { should validate_presence_of(attribute) }
  end
  [:user_id, :supervision_id].each do |attribute|
    it { should_not allow_mass_assignment_of(attribute) }
  end

  describe "after create" do
    it "should publish question to Redis channel" do
      @question = FactoryGirl.build(:question)
      @question.should_receive(:publish_to_redis)
      @question.save!
    end
  end

  it "should include SupervisionRedisPublisher module" do
    Question.new.should respond_to(:publish_to_redis)
  end

  describe "#supervision_publish_attributed" do
    it "should have only known options" do
      @answer = Question.new
      @answer.supervision_publish_attributes.should be == {:only => [:id, :content, :user_id]}
    end
  end
end
