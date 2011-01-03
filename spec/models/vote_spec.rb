require 'spec_helper'

describe Vote do
  it "should create a new instance given valid attributes" do
    Factory.build(:vote).valid?.should be_true
  end

  describe "user attribute" do
    it "should be required" do
      @vote = Factory.build(:vote, :user => nil)
      @vote.valid?.should be_false
      @vote.should have(1).error_on(:user)
    end

    it "should be protected against mass assignment" do
      @user = Factory.build(:user)
      @vote = Factory.build(:vote, :user => @user)
      @another_user = Factory.build(:user)

      @vote.attributes = { :user => @another_user }
      @vote.user.should be == @user
    end
  end

  describe "statement attribute" do
    it "should be required" do
      # I had to add :user, or factory would fail
      @vote = Factory.build(:vote, :statement => nil, :user => Factory(:user))
      @vote.valid?.should be_false
    end

    it "should be protected agains mass assignment" do
      @topic = Factory.build(:topic)
      @vote = Factory.build(:vote, :statement => @topic)
      @another_topic = Factory.build(:topic)

      @vote.attributes = { :statement => @another_topic }
      @vote.statement.should be == @topic
    end
  end

  describe "after create" do
    it "should notify supervision with #post_topic_vote" do
      @topic = Factory(:topic)
      @topic.supervision.should_receive(:post_topic_vote)
      @vote = Factory(:vote, :statement => @topic)
    end

    it "should notify spervision with #post_vote_for_next_step" do
      @supervision = Factory(:supervision)
      @supervision.should_receive(:post_vote_for_next_step)
      @vote = Factory(:supervision_vote, :statement => @supervision)
    end

    it "should publish vote to Redis channel" do
      @vote = Factory.build(:vote)
      @vote.should_receive(:publish_to_redis)
      @vote.save!
    end

    it "should publish vote to Redis channel" do
      @vote = Factory.build(:supervision_vote)
      @vote.should_receive(:publish_to_redis)
      @vote.save!
    end
  end

  it "should include SupervisionRedisPublisher module" do
    included_modules = Vote.send :included_modules
    included_modules.should include(SupervisionRedisPublisher)
  end

  describe "#supervision_publish_attributed" do
    it "should have only known options" do
      @answer = Vote.new
      @answer.supervision_publish_attributes.should be == {:only => [:id, :statement_type, :statement_id, :user_id]}
    end
  end

end
