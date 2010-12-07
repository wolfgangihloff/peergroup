require 'spec_helper'

describe Supervision do
  before do
    @topic = Factory(:topic)
    @user = @topic.user
    @supervision = @topic.supervision
  end

  describe "state machine" do
    it "should be in topic state after create" do
      Supervision.new.state.should == "topic"
    end

    it "should change from topic to topic_vote" do
      supervision = Factory(:supervision, :state => "topic")

      supervision.should_receive(:all_topics?).and_return(true)
      supervision.post_topic!
      supervision.state.should == "topic_vote"
    end

    it "should change from topic_vote to topic_question" do
      supervision = Factory(:supervision, :state => "topic_vote")

      supervision.should_receive(:all_topic_votes?).and_return(true)
      supervision.post_topic_vote!
      supervision.state.should == "topic_question"
    end

    it "should change from topic_question to idea" do
      supervision = Factory(:supervision, :state => "topic_question")

      supervision.should_receive(:all_answers?).and_return(true)
      supervision.should_receive(:all_next_step_votes?).and_return(true)
      supervision.post_vote_for_next_step!
      supervision.state.should == "idea"
    end

    it "should change from idea to idea_feedback" do
      supervision = Factory(:supervision, :state => "idea")

      supervision.should_receive(:all_idea_ratings?).and_return(true)
      supervision.should_receive(:all_next_step_votes?).and_return(true)
      supervision.post_vote_for_next_step!
      supervision.state.should == "idea_feedback"
    end

    it "should change from idea_feedback to solution" do
      supervision = Factory(:supervision, :state => "idea_feedback")

      supervision.owner_idea_feedback!
      supervision.state.should == "solution"
    end

    it "should change from solution to solution_feedback" do
      supervision = Factory(:supervision, :state => "solution")

      supervision.should_receive(:all_solution_ratings?).and_return(true)
      supervision.should_receive(:all_next_step_votes?).and_return(true)
      supervision.post_vote_for_next_step!
      supervision.state.should == "solution_feedback"
    end

    it "should change from solution_feedback to supervision_feedback" do
      supervision = Factory(:supervision, :state => "solution_feedback")

      supervision.owner_solution_feedback!
      supervision.state.should == "supervision_feedback"
    end

    it "should change from supervision_feedback to finished" do
      supervision = Factory(:supervision, :state => "supervision_feedback")

      supervision.general_feedback!
      supervision.state.should == "finished"
    end
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

  describe "all_answers?" do
    before do
      @questions = Array.new(2) { Factory(:question, :supervision => @supervision) }
    end

    it "should be true when all answers provided" do
      @questions.each {|q| Factory(:answer, :question => q) }

      @supervision.all_answers?.should be_true
    end

    it "should be false when some answers are missing" do
      Factory(:answer, :question => @questions.first)

      @supervision.all_answers?.should be_false
    end
  end
end

