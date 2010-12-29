require 'spec_helper'

describe Supervision do
  describe "state machine" do
    it "should be in topic state after create" do
      Supervision.new.state.should == "topic"
    end

    it "should change from topic to topic_vote" do
      @topic = Factory.build(:topic)
      @supervision = Factory(:supervision, :state => "topic")

      @supervision.should_receive(:all_topics?).and_return(true)
      @supervision.should_receive(:publish_transition_change)
      @supervision.post_topic!(@topic)
      @supervision.state.should be == "topic_vote"
    end

    it "should change from topic_vote to topic_question" do
      @supervision = Factory(:supervision, :state => "topic_vote")

      @supervision.should_receive(:all_topic_votes?).and_return(true)
      @supervision.should_receive(:choose_topic)
      @supervision.should_receive(:publish_transition_change)
      @supervision.post_topic_vote!
      @supervision.state.should be == "topic_question"
    end


    it "should change from topic_question to idea" do
      @supervision = Factory(:supervision, :state => "topic_question")

      @supervision.should_receive(:all_answers?).and_return(true)
      @supervision.should_receive(:all_next_step_votes?).and_return(true)
      @supervision.should_receive(:publish_transition_change)
      @supervision.should_receive(:destroy_next_step_votes)
      @supervision.post_vote_for_next_step!
      @supervision.state.should be == "idea"
    end

    it "should change from idea to idea_feedback" do
      @supervision = Factory(:supervision, :state => "idea")

      @supervision.should_receive(:all_idea_ratings?).and_return(true)
      @supervision.should_receive(:all_next_step_votes?).and_return(true)
      @supervision.should_receive(:publish_transition_change)
      @supervision.should_receive(:destroy_next_step_votes)
      @supervision.post_vote_for_next_step!
      @supervision.state.should be == "idea_feedback"
    end

    it "should change from idea_feedback to solution" do
      @supervision = Factory(:supervision, :state => "idea_feedback")

      @supervision.owner_idea_feedback!
      @supervision.state.should be == "solution"
    end

    it "should change from solution to solution_feedback" do
      @supervision = Factory(:supervision, :state => "solution")

      @supervision.should_receive(:all_solution_ratings?).and_return(true)
      @supervision.should_receive(:all_next_step_votes?).and_return(true)
      @supervision.should_receive(:publish_transition_change)
      @supervision.should_receive(:destroy_next_step_votes)
      @supervision.post_vote_for_next_step!
      @supervision.state.should be == "solution_feedback"
    end

    it "should change from solution_feedback to supervision_feedback" do
      @supervision = Factory(:supervision, :state => "solution_feedback")

      @supervision.should_receive(:publish_transition_change)
      @supervision.owner_solution_feedback!
      @supervision.state.should be == "supervision_feedback"
    end

    it "should change from supervision_feedback to finished" do
      @supervision = Factory(:supervision, :state => "supervision_feedback")

      @supervision.should_receive(:all_supervision_feedbacks?).and_return(true)
      @supervision.should_receive(:publish_transition_change)
      @supervision.general_feedback!
      @supervision.state.should be == "finished"
    end
  end

  describe "#voted_on_topic?" do
    it "should be true when user already voted on topic" do
      @supervision = Factory(:supervision)
      @topic = Factory(:topic, :supervision => @supervision)
      @user = @topic.user
      @topic.votes.create! do |vote|
        vote.user = @user
      end
      @supervision.voted_on_topic?(@user).should be_true
    end

    it "should be false when user not yet voted on topic" do
      @supervision = Factory(:supervision)
      @user = @supervision.group.founder
      @supervision.voted_on_topic?(@user).should be_false
    end
  end

  describe "#choose_topic" do
    it "should choose topic with the most votes" do
      @supervision = Factory(:supervision)
      @topic = Factory(:topic, :supervision => @supervision)
      @second_topic = Factory(:topic, :supervision => @supervision)
      Factory(:vote, :statement => @topic)
      @supervision.choose_topic
      @supervision.topic.should be == @topic
    end
  end

  describe "#all_answers?" do
    before do
      @supervision = Factory(:supervision)
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

  describe "#step_finished?" do
    before do
      @supervision = Factory.build(:supervision)
    end
    it "should use Supervision::STATES and it should be correct" do
      Supervision::STATES.should == %w/ topic topic_vote topic_question idea idea_feedback solution solution_feedback supervision_feedback finished /
    end

    it "should be correct for :topic state" do
      @supervision.state = "topic"
      @supervision.step_finished?("topic").should be_false
      @supervision.step_finished?("topic_vote").should be_false
      @supervision.step_finished?("topic_question").should be_false
      @supervision.step_finished?("idea").should be_false
      @supervision.step_finished?("idea_feedback").should be_false
      @supervision.step_finished?("solution").should be_false
      @supervision.step_finished?("solution_feedback").should be_false
      @supervision.step_finished?("supervision_feedback").should be_false
      @supervision.step_finished?("finished").should be_false
    end

    it "should be correct for :topic_vote state" do
      @supervision.state = "topic_vote"
      @supervision.step_finished?("topic").should be_true
      @supervision.step_finished?("topic_vote").should be_false
      @supervision.step_finished?("topic_question").should be_false
      @supervision.step_finished?("idea").should be_false
      @supervision.step_finished?("idea_feedback").should be_false
      @supervision.step_finished?("solution").should be_false
      @supervision.step_finished?("solution_feedback").should be_false
      @supervision.step_finished?("supervision_feedback").should be_false
      @supervision.step_finished?("finished").should be_false
    end

    it "should be correct for :topic_question state" do
      @supervision.state = "topic_question"
      @supervision.step_finished?("topic").should be_true
      @supervision.step_finished?("topic_vote").should be_true
      @supervision.step_finished?("topic_question").should be_false
      @supervision.step_finished?("idea").should be_false
      @supervision.step_finished?("idea_feedback").should be_false
      @supervision.step_finished?("solution").should be_false
      @supervision.step_finished?("solution_feedback").should be_false
      @supervision.step_finished?("supervision_feedback").should be_false
      @supervision.step_finished?("finished").should be_false
    end

    it "should be correct for :idea state" do
      @supervision.state = "idea"
      @supervision.step_finished?("topic").should be_true
      @supervision.step_finished?("topic_vote").should be_true
      @supervision.step_finished?("topic_question").should be_true
      @supervision.step_finished?("idea").should be_false
      @supervision.step_finished?("idea_feedback").should be_false
      @supervision.step_finished?("solution").should be_false
      @supervision.step_finished?("solution_feedback").should be_false
      @supervision.step_finished?("supervision_feedback").should be_false
      @supervision.step_finished?("finished").should be_false
    end

    it "should be correct for :idea_feedback state" do
      @supervision.state = "idea_feedback"
      @supervision.step_finished?("topic").should be_true
      @supervision.step_finished?("topic_vote").should be_true
      @supervision.step_finished?("topic_question").should be_true
      @supervision.step_finished?("idea").should be_true
      @supervision.step_finished?("idea_feedback").should be_false
      @supervision.step_finished?("solution").should be_false
      @supervision.step_finished?("solution_feedback").should be_false
      @supervision.step_finished?("supervision_feedback").should be_false
      @supervision.step_finished?("finished").should be_false
    end

    it "should be correct for :solution state" do
      @supervision.state = "solution"
      @supervision.step_finished?("topic").should be_true
      @supervision.step_finished?("topic_vote").should be_true
      @supervision.step_finished?("topic_question").should be_true
      @supervision.step_finished?("idea").should be_true
      @supervision.step_finished?("idea_feedback").should be_true
      @supervision.step_finished?("solution").should be_false
      @supervision.step_finished?("solution_feedback").should be_false
      @supervision.step_finished?("supervision_feedback").should be_false
      @supervision.step_finished?("finished").should be_false
    end

    it "should be correct for :solution_feedback state" do
      @supervision.state = "solution_feedback"
      @supervision.step_finished?("topic").should be_true
      @supervision.step_finished?("topic_vote").should be_true
      @supervision.step_finished?("topic_question").should be_true
      @supervision.step_finished?("idea").should be_true
      @supervision.step_finished?("idea_feedback").should be_true
      @supervision.step_finished?("solution").should be_true
      @supervision.step_finished?("solution_feedback").should be_false
      @supervision.step_finished?("supervision_feedback").should be_false
      @supervision.step_finished?("finished").should be_false
    end

    it "should be correct for :supervision_feedback state" do
      @supervision.state = "supervision_feedback"
      @supervision.step_finished?("topic").should be_true
      @supervision.step_finished?("topic_vote").should be_true
      @supervision.step_finished?("topic_question").should be_true
      @supervision.step_finished?("idea").should be_true
      @supervision.step_finished?("idea_feedback").should be_true
      @supervision.step_finished?("solution").should be_true
      @supervision.step_finished?("solution_feedback").should be_true
      @supervision.step_finished?("supervision_feedback").should be_false
      @supervision.step_finished?("finished").should be_false
    end

    it "should be correct for :finished state" do
      @supervision.state = "finished"
      @supervision.step_finished?("topic").should be_true
      @supervision.step_finished?("topic_vote").should be_true
      @supervision.step_finished?("topic_question").should be_true
      @supervision.step_finished?("idea").should be_true
      @supervision.step_finished?("idea_feedback").should be_true
      @supervision.step_finished?("solution").should be_true
      @supervision.step_finished?("solution_feedback").should be_true
      @supervision.step_finished?("supervision_feedback").should be_true
      @supervision.step_finished?("finished").should be_false
    end
  end
end

