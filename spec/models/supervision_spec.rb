require 'spec_helper'

describe Supervision do
  it "should create a new instance given valid attributes" do
    Factory(:supervision)
  end

  describe "voted_on_topic?" do
    before do
      @topic = Factory(:topic)
      @user = @topic.author
      @supervision = @topic.supervision
    end

    it "should be true when user already voted on topic" do
      @topic.votes.create!(:user => @user)
      @supervision.voted_on_topic?(@user).should be_true
    end

    it "should be false when user not yet voted on topic" do
      @supervision.voted_on_topic?(@user).should be_false
    end
  end
end
