require 'spec_helper'

describe Supervision do
  describe "state machine" do
    it "should be in topic state after create" do
      Supervision.new.state.should == "topic"
    end

    it "should change from topic to topic_vote" do
      @topic = Factory.build(:topic)
      @supervision = Factory.build(:supervision, :state => "topic")

      @supervision.should_receive(:all_topics?).and_return(true)
      @supervision.should_receive(:publish_transition_change)
      @supervision.post_topic!(@topic)
      @supervision.state.should be == "topic_vote"
    end

    it "should change from topic_vote to topic_question" do
      @supervision = Factory.build(:supervision, :state => "topic_vote")

      @supervision.should_receive(:all_topic_votes?).and_return(true)
      @supervision.should_receive(:choose_topic)
      @supervision.should_receive(:publish_transition_change)
      @supervision.post_topic_vote!(Vote.new)
      @supervision.state.should be == "topic_question"
    end


    it "should change from topic_question to idea" do
      @supervision = Factory.build(:supervision, :state => "topic_question")

      @supervision.should_receive(:all_answers?).and_return(true)
      @supervision.should_receive(:all_next_step_votes?).and_return(true)
      @supervision.should_receive(:publish_transition_change)
      @supervision.should_receive(:destroy_next_step_votes)
      @supervision.post_vote_for_next_step!(Vote.new)
      @supervision.state.should be == "idea"
    end

    it "should change from idea to idea_feedback" do
      @supervision = Factory.build(:supervision, :state => "idea")

      @supervision.should_receive(:all_idea_ratings?).and_return(true)
      @supervision.should_receive(:all_next_step_votes?).and_return(true)
      @supervision.should_receive(:publish_transition_change)
      @supervision.should_receive(:destroy_next_step_votes)
      @supervision.post_vote_for_next_step!(Vote.new)
      @supervision.state.should be == "idea_feedback"
    end

    it "should change from idea_feedback to solution" do
      @supervision = Factory.build(:supervision, :state => "idea_feedback")

      @supervision.post_ideas_feedback!(IdeasFeedback.new)
      @supervision.state.should be == "solution"
    end

    it "should change from solution to solution_feedback" do
      @supervision = Factory.build(:supervision, :state => "solution")

      @supervision.should_receive(:all_solution_ratings?).and_return(true)
      @supervision.should_receive(:all_next_step_votes?).and_return(true)
      @supervision.should_receive(:publish_transition_change)
      @supervision.should_receive(:destroy_next_step_votes)
      @supervision.post_vote_for_next_step!(Vote.new)
      @supervision.state.should be == "solution_feedback"
    end

    it "should change from solution_feedback to supervision_feedback" do
      @supervision = Factory.build(:supervision, :state => "solution_feedback")

      @supervision.should_receive(:publish_transition_change)
      @supervision.post_solutions_feedback!(SolutionsFeedback.new)
      @supervision.state.should be == "supervision_feedback"
    end

    it "should change from supervision_feedback to finished" do
      @supervision = Factory.build(:supervision, :state => "supervision_feedback")

      @supervision.should_receive(:all_supervision_feedbacks?).and_return(true)
      @supervision.should_receive(:publish_transition_change)
      @supervision.post_supervision_feedback!(SupervisionFeedback.new)
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

  describe "#destroy_next_step_votes" do

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

  describe "#can_move_to_idea_state?" do
    it "should check all next step votes and all answers" do
      @supervision = Factory.build(:supervision)
      @supervision.should_receive(:all_next_step_votes?).and_return(true)
      @supervision.should_receive(:all_answers?).and_return(true)
      @supervision.can_move_to_idea_state?.should be_true
    end

    it "should be false when not all next step voted" do
      @supervision = Factory.build(:supervision)
      @supervision.should_receive(:all_next_step_votes?).and_return(false)
      @supervision.should_not_receive(:all_answers?)
      @supervision.can_move_to_idea_state?.should be_false
    end

    it "should be false when no all answers" do
      @supervision = Factory.build(:supervision)
      @supervision.should_receive(:all_next_step_votes?).and_return(true)
      @supervision.should_receive(:all_answers?).and_return(false)
      @supervision.can_move_to_idea_state?.should be_false
    end
  end

  describe "#can_move_to_idea_feedback_state?" do
    it "should check all next step votes and all idea ratings" do
      @supervision = Factory.build(:supervision)
      @supervision.should_receive(:all_next_step_votes?).and_return(true)
      @supervision.should_receive(:all_idea_ratings?).and_return(true)
      @supervision.can_move_to_idea_feedback_state?.should be_true
    end

    it "should be false if not all next step votes" do
      @supervision = Factory.build(:supervision)
      @supervision.should_receive(:all_next_step_votes?).and_return(false)
      @supervision.should_not_receive(:all_idea_ratings?)
      @supervision.can_move_to_idea_feedback_state?.should be_false
    end

    it "should be false if not all idea retings" do
      @supervision = Factory.build(:supervision)
      @supervision.should_receive(:all_next_step_votes?).and_return(true)
      @supervision.should_receive(:all_idea_ratings?).and_return(false)
      @supervision.can_move_to_idea_feedback_state?.should be_false
    end
  end

  describe "#can_move_to_solution_feedback_state?" do
    it "should check all next step votes and all solution ratings" do
      @supervision = Factory(:supervision)
      @supervision.should_receive(:all_next_step_votes?).and_return(true)
      @supervision.should_receive(:all_solution_ratings?).and_return(true)
      @supervision.can_move_to_solution_feedback_state?.should be_true
    end

    it "should be false if not all next step votes" do
      @supervision = Factory(:supervision)
      @supervision.should_receive(:all_next_step_votes?).and_return(false)
      @supervision.should_not_receive(:all_solution_ratings?)
      @supervision.can_move_to_solution_feedback_state?.should be_false
    end

    it "should be false if not all solution ratings" do
      @supervision = Factory(:supervision)
      @supervision.should_receive(:all_next_step_votes?).and_return(true)
      @supervision.should_receive(:all_solution_ratings?).and_return(false)
      @supervision.can_move_to_solution_feedback_state?.should be_false
    end
  end

  describe "#can_move_to_finished_state?" do
    it "should check all supervision feedbacks" do
      @supervision = Factory(:supervision)
      @supervision.should_receive(:all_supervision_feedbacks?).and_return(true)
      @supervision.can_move_to_finished_state?.should be_true
    end

    it "should be false if not all supervision feedbacks" do
      @supervision = Factory(:supervision)
      @supervision.should_receive(:all_supervision_feedbacks?).and_return(false)
      @supervision.can_move_to_finished_state?.should be_false
    end
  end

  describe "#all_topics?" do
  end

  describe "#all_topic_votes?" do
  end

  describe "#all_next_step_votes?" do
  end

  describe "#all_answers?" do
  end

  describe "#all_idea_ratings?" do
  end

  describe "#all_solution_ratings?" do
  end

  describe "#all_supervision_feedbacks?" do
  end

  describe "#destroy_next_step_votes" do
    it "should delete all next step voted" do
      @supervision = Factory(:supervision)
      @supervision.next_step_votes.create! { |v| v.user = Factory(:user) }
      @supervision.destroy_next_step_votes
      @supervision.next_step_votes.count.should be == 0
    end
  end

  describe "#posted_topic?" do
    it "should be false if no topics present" do
      @supervision = Factory(:supervision)
      @user = Factory(:user)
      @supervision.posted_topic?(@user).should be_false
    end

    it "should be false if user haven't posted topic" do
      @supervision = Factory(:supervision)
      @user = Factory(:user)
      @supervision.topics.create { |t| t.user,t.content = Factory(:user),"topic" }
      @supervision.posted_topic?(@user).should be_false
    end

    it "should be true if user posted topic" do
      @supervision = Factory(:supervision)
      @user = Factory(:user)
      @supervision.topics.create { |t| t.user,t.content = @user,"topic" }
      @supervision.posted_topic?(@user).should be_true
    end
  end

  describe "#voted_on_topic?" do
    it "should be false if no votes on topics" do
      @supervision = Factory(:supervision)
      @user = Factory(:user)
      @supervision.voted_on_topic?(@user).should be_false
    end

    it "should be false if user haven't voted" do
      @supervision = Factory(:supervision)
      @topic = Factory(:topic, :supervision => @supervision)
      @user = Factory(:user)
      @topic.votes.create { |v| v.user = Factory(:user) }
      @supervision.voted_on_topic?(@user).should be_false
    end

    it "should be true if user voted" do
      @supervision = Factory(:supervision)
      @topic = Factory(:topic, :supervision => @supervision)
      @user = Factory(:user)
      @topic.votes.create { |v| v.user = @user }
      @supervision.voted_on_topic?(@user).should be_true
    end
  end

  describe "#voted_on_next_step?" do
    it "should be false if no next step votes present" do
      @supervision = Factory(:supervision)
      @user = Factory(:user)
      @supervision.voted_on_next_step?(@user).should be_false
    end

    it "should be false if user haven't voted on next step" do
      @supervision = Factory(:supervision)
      @user = Factory(:user)
      @supervision.next_step_votes.create { |v| v.user = Factory(:user) }
      @supervision.voted_on_next_step?(@user).should be_false
    end

    it "should be true if user voted on next step" do
      @supervision = Factory(:supervision)
      @user = Factory(:user)
      @supervision.next_step_votes.create { |v| v.user = @user }
      @supervision.voted_on_next_step?(@user).should be_true
    end
  end

  describe "#posted_supervision_feedback?" do
    it "should be false when no supervision feedbacks present" do
      @supervision = Factory(:supervision)
      @user = Factory(:user)
      @supervision.posted_supervision_feedback?(@user).should be_false
    end

    it "should be false when user haven't posted feedback" do
      @supervision = Factory(:supervision)
      @user = Factory(:user)
      @feedback = Factory(:supervision_feedback, :supervision => @supervision)
      @supervision.posted_supervision_feedback?(@user).should be_false
    end

    it "should be true when user posted feedback" do
      @supervision = Factory(:supervision)
      @user = Factory(:user)
      @feedback = Factory(:supervision_feedback, :supervision => @supervision, :user => @user)
      @supervision.posted_supervision_feedback?(@user).should be_true
    end
  end

  describe "#choose_topic" do
    it "should assign topic with most votes" do
      @supervision = Factory(:supervision)
      @topic = Factory(:topic, :supervision => @supervision)
      @another_topic = Factory(:topic, :supervision => @supervision)
      @topic.votes.create { |v| v.user = Factory(:user) }
      @topic.votes.create { |v| v.user = Factory(:user) }
      @another_topic.votes { |v| v.user = Factory(:user) }

      @supervision.choose_topic
      @supervision.topic.should be == @topic
    end

    it "should assign only topic even if it has no votes" do
      @supervision = Factory(:supervision)
      @topic = Factory(:topic, :supervision => @supervision)
      @supervision.choose_topic
      @supervision.topic.should be == @topic
    end
  end

  describe "#problem_owner" do
    it "should be nil when no current topic" do
      @topic = Factory.build(:topic)
      @supervision = Factory.build(:supervision, :topic => nil)
      @supervision.topics << @topic
      @supervision.problem_owner.should be_nil
    end

    it "should be owner of topic" do
      @topic = Factory.build(:topic)
      @supervision = Factory.build(:supervision, :topic => @topic)
      @supervision.topics << @topic
      @supervision.problem_owner.should be == @topic.user
    end
  end

  describe "#problem_owner?" do
    it "should be false when no current topic" do
      @topic = Factory.build(:topic)
      @supervision = Factory.build(:supervision, :topic => nil)
      @supervision.topics << @topic
      @supervision.problem_owner?(@topic.user).should be_false
    end

    it "should be false if user is no author of current topic" do
      @topic = Factory.build(:topic)
      @another_topic = Factory.build(:topic)

      @supervision = Factory.build(:supervision, :topic => @topic)
      @supervision.topics << @topic
      @supervision.topics << @another_topic
      @supervision.problem_owner?(@another_topic.user).should be_false
    end

    it "should be true if user is author of current topic" do
      @topic = Factory.build(:topic)
      @another_topic = Factory.build(:topic)

      @supervision = Factory.build(:supervision, :topic => @topic)
      @supervision.topics << @topic
      @supervision.topics << @another_topic
      @supervision.problem_owner?(@topic.user).should be_true
    end
  end

  describe "#publish_transition_change" do
  end

  describe "#post_topic" do
  end

  describe "#post_topic_vote" do
  end

  describe "#post_vote_for_next_step" do
  end

  describe "#post_ideas_feedback" do
  end

  describe "#post_solutions_feedback" do
  end

  describe "#post_general_feedback" do
  end

end

