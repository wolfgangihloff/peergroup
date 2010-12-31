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
      @vote = Factory.build(:vote, :statement => @topic)
      @topic.supervision.should_receive(:post_topic_vote).with(@vote)
      @vote.save!
    end

    it "should notify spervision with #post_vote_for_next_step" do
      @supervision = Factory(:supervision)
      @vote = Factory.build(:supervision_vote, :statement => @supervision)
      @supervision.should_receive(:post_vote_for_next_step).with(@vote)
      @vote.save!
    end
  end

end
