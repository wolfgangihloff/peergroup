require 'spec_helper'

describe Supervision do
  before do
    @topic = Factory(:topic)
    @user = @topic.user
    @supervision = @topic.supervision
  end

  describe "voted_on_topic?" do
    it "should be true when user already voted on topic" do
      @topic.votes.create!(:user => @user)
      @supervision.voted_on_topic?(@user).should be_true
    end

    it "should be false when user not yet voted on topic" do
      @supervision.voted_on_topic?(@user).should be_false
    end
  end

  describe "choose_topic" do
    it "should choose topic with the most votes" do
      @second_topic = Factory(:topic, :supervision => @supervision)
      Factory(:vote, :statement => @topic)
      @supervision.choose_topic
      @supervision.topic.should == @topic
    end
  end
end
