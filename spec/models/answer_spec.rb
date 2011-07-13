require "spec_helper"

describe Answer do

  [:user, :question, :content].each do |attribute|
    it { should validate_presence_of(attribute) }
  end
  [:user_id, :question_id].each do |attribute|
    it { should_not allow_mass_assignment_of(attribute) }
  end

  describe "supervision attribute" do
    it "shuld delegate to question" do
      @question = FactoryGirl.build(:question)
      @answer = FactoryGirl.build(:answer, :question => @question)
      @question.should_receive(:supervision).and_return("supervision")
      @answer.supervision.should be == "supervision"
    end
  end

  describe "after create" do
    it "should notify supervision with #post_vote_for_next_step" do
      @supervision = FactoryGirl.create(:supervision)
      @supervision.should_receive(:post_vote_for_next_step)
      @question = FactoryGirl.create(:question, :supervision => @supervision)
      @answer = FactoryGirl.create(:answer, :question => @question)
    end

    it "should publish answer to Redis channel" do
      @answer = FactoryGirl.build(:answer)
      @answer.should_receive(:publish_to_redis)
      @answer.save!
    end
  end

  it "should include SupervisionRedisPublisher module" do
    Answer.new.should respond_to(:publish_to_redis)
  end

  describe "#supervision_publish_attributed" do
    it "should have only known options" do
      @answer = Answer.new
      @answer.supervision_publish_attributes.should == {:only => [:id, :content, :question_id, :user_id]}
    end
  end
end
