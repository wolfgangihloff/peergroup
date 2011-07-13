require 'spec_helper'

describe Vote do
  [:user, :statement].each do |attribute|
    it { should validate_presence_of(attribute) }
  end
  [:user_id, :statement].each do |attribute|
    it { should_not allow_mass_assignment_of(attribute) }
  end

  describe "after create" do
    it "should notify supervision with #post_topic_vote" do
      @topic = FactoryGirl.create(:topic)
      @topic.supervision.should_receive(:post_topic_vote)
      @vote = FactoryGirl.create(:vote, :statement => @topic)
    end

    it "should notify spervision with #post_vote_for_next_step" do
      @supervision = FactoryGirl.create(:supervision)
      @supervision.should_receive(:post_vote_for_next_step)
      @vote = FactoryGirl.create(:supervision_vote, :statement => @supervision)
    end

    it "should publish vote to Redis channel" do
      @vote = FactoryGirl.build(:vote)
      @vote.should_receive(:publish_to_redis)
      @vote.save!
    end

    it "should publish vote to Redis channel" do
      @vote = FactoryGirl.build(:supervision_vote)
      @vote.should_receive(:publish_to_redis)
      @vote.save!
    end
  end

  it "should include SupervisionRedisPublisher module" do
    Vote.new.should respond_to(:publish_to_redis)
  end

  describe "#supervision_publish_attributed" do
    it "should have only known options" do
      @answer = Vote.new
      @answer.supervision_publish_attributes.should == {:only => [:id, :statement_type, :statement_id, :user_id]}
    end
  end
end
