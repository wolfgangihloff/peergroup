require 'spec_helper'

describe Topic do
  [:user, :supervision].each do |attribute|
    it { should validate_presence_of(attribute) }
  end
  [:user_id, :supervision_id].each do |attribute|
    it { should_not allow_mass_assignment_of(attribute) }
  end

  describe "after create" do
    it "should fire #post_topic event on supervision" do
      @supervision = Factory(:supervision)
      @supervision.should_receive(:post_topic)
      @topic = Factory(:topic, :supervision => @supervision)
    end

    it "should publish topic to Redis channel" do
      @topic = Factory.build(:topic)
      @topic.should_receive(:publish_to_redis)
      @topic.save!
    end
  end

  it "should include SupervisionRedisPublisher module" do
    Topic.new.should respond_to(:publish_to_redis)
  end

  describe "#supervision_publish_attributed" do
    it "should have only known options" do
      @answer = Topic.new
      @answer.supervision_publish_attributes.should == {:only => [:id, :content, :user_id]}
    end
  end
end
