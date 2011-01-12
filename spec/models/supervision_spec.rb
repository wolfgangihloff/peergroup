require 'spec_helper'

describe Supervision do
  describe "state machine" do
    it "should be in gathering_topics state after create" do
      @supervision = Supervision.new

      @supervision.state.should == "gathering_topics"
      @supervision.gathering_topics?.should be_true
    end

    it "should change from gathering_topics to voting_on_topics" do
      @topic = Factory.build(:topic)
      @supervision = Factory.build(:supervision, :state => "gathering_topics")

      @supervision.should_receive(:all_topics?).and_return(true)
      @supervision.should_receive(:publish_to_redis)
      @supervision.post_topic!(@topic)

      @supervision.state.should be == "voting_on_topics"
      @supervision.voting_on_topics?.should be_true
    end

    it "should change from voting_on_topics to asking_questions" do
      @supervision = Factory.build(:supervision, :state => "voting_on_topics")

      @supervision.should_receive(:all_topic_votes?).and_return(true)
      @supervision.should_receive(:choose_topic)
      @supervision.should_receive(:publish_to_redis)
      @supervision.post_topic_vote!(Vote.new)

      @supervision.state.should be == "asking_questions"
      @supervision.asking_questions?.should be_true
    end


    it "should change from asking_questions to providing_ideas" do
      @supervision = Factory.build(:supervision, :state => "asking_questions")

      @supervision.should_receive(:all_answers?).and_return(true)
      @supervision.should_receive(:all_next_step_votes?).and_return(true)
      @supervision.should_receive(:publish_to_redis)
      @supervision.should_receive(:destroy_next_step_votes)
      @supervision.post_vote_for_next_step!(Vote.new)

      @supervision.state.should be == "providing_ideas"
      @supervision.providing_ideas?.should be_true
    end

    it "should change from providing_ideas to giving_ideas_feedback" do
      @supervision = Factory.build(:supervision, :state => "providing_ideas")

      @supervision.should_receive(:all_idea_ratings?).and_return(true)
      @supervision.should_receive(:all_next_step_votes?).and_return(true)
      @supervision.should_receive(:publish_to_redis)
      @supervision.should_receive(:destroy_next_step_votes)
      @supervision.post_vote_for_next_step!(Vote.new)

      @supervision.state.should be == "giving_ideas_feedback"
      @supervision.giving_ideas_feedback?.should be_true
    end

    it "should change from giving_ideas_feedback to providing_solutions" do
      @supervision = Factory.build(:supervision, :state => "giving_ideas_feedback")

      @supervision.post_ideas_feedback!(IdeasFeedback.new)

      @supervision.state.should be == "providing_solutions"
      @supervision.providing_solutions?.should be_true
    end

    it "should change from providing_solutions to giving_solutions_feedback" do
      @supervision = Factory.build(:supervision, :state => "providing_solutions")

      @supervision.should_receive(:all_solution_ratings?).and_return(true)
      @supervision.should_receive(:all_next_step_votes?).and_return(true)
      @supervision.should_receive(:publish_to_redis)
      @supervision.should_receive(:destroy_next_step_votes)
      @supervision.post_vote_for_next_step!(Vote.new)

      @supervision.state.should be == "giving_solutions_feedback"
      @supervision.giving_solutions_feedback?.should be_true
    end

    it "should change from giving_solutions_feedback to giving_supervision_feedbacks" do
      @supervision = Factory.build(:supervision, :state => "giving_solutions_feedback")

      @supervision.should_receive(:publish_to_redis)
      @supervision.post_solutions_feedback!(SolutionsFeedback.new)

      @supervision.state.should be == "giving_supervision_feedbacks"
      @supervision.giving_supervision_feedbacks?.should be_true
    end

    it "should change from giving_supervision_feedbacks to finished" do
      @supervision = Factory.build(:supervision, :state => "giving_supervision_feedbacks")

      @supervision.should_receive(:all_supervision_feedbacks?).and_return(true)
      @supervision.should_receive(:publish_to_redis)
      @supervision.post_supervision_feedback!(SupervisionFeedback.new)

      @supervision.state.should be == "finished"
      @supervision.finished?.should be_true
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
      REDIS.stub(:publish)
      @questions.each {|q| Factory(:answer, :question => q) }

      @supervision.all_answers?.should be_true
    end

    it "should be false when some answers are missing" do
      REDIS.stub(:publish)
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
      Supervision::STATES.should == %w/ gathering_topics voting_on_topics asking_questions providing_ideas giving_ideas_feedback providing_solutions giving_solutions_feedback giving_supervision_feedbacks finished /
    end

    it "should be correct for :topics state" do
      @supervision.state = "gathering_topics"
      @supervision.step_finished?("gathering_topics").should be_false
      @supervision.step_finished?("voting_on_topics").should be_false
      @supervision.step_finished?("asking_questions").should be_false
      @supervision.step_finished?("providing_ideas").should be_false
      @supervision.step_finished?("giving_ideas_feedback").should be_false
      @supervision.step_finished?("providing_solutions").should be_false
      @supervision.step_finished?("giving_solutions_feedback").should be_false
      @supervision.step_finished?("giving_supervision_feedbacks").should be_false
      @supervision.step_finished?("finished").should be_false
    end

    it "should be correct for :topic_votes state" do
      @supervision.state = "voting_on_topics"
      @supervision.step_finished?("gathering_topics").should be_true
      @supervision.step_finished?("voting_on_topics").should be_false
      @supervision.step_finished?("asking_questions").should be_false
      @supervision.step_finished?("providing_ideas").should be_false
      @supervision.step_finished?("giving_ideas_feedback").should be_false
      @supervision.step_finished?("providing_solutions").should be_false
      @supervision.step_finished?("giving_solutions_feedback").should be_false
      @supervision.step_finished?("giving_supervision_feedbacks").should be_false
      @supervision.step_finished?("finished").should be_false
    end

    it "should be correct for :questions state" do
      @supervision.state = "asking_questions"
      @supervision.step_finished?("gathering_topics").should be_true
      @supervision.step_finished?("voting_on_topics").should be_true
      @supervision.step_finished?("asking_questions").should be_false
      @supervision.step_finished?("providing_ideas").should be_false
      @supervision.step_finished?("giving_ideas_feedback").should be_false
      @supervision.step_finished?("providing_solutions").should be_false
      @supervision.step_finished?("giving_solutions_feedback").should be_false
      @supervision.step_finished?("giving_supervision_feedbacks").should be_false
      @supervision.step_finished?("finished").should be_false
    end

    it "should be correct for :ideas state" do
      @supervision.state = "providing_ideas"
      @supervision.step_finished?("gathering_topics").should be_true
      @supervision.step_finished?("voting_on_topics").should be_true
      @supervision.step_finished?("asking_questions").should be_true
      @supervision.step_finished?("providing_ideas").should be_false
      @supervision.step_finished?("giving_ideas_feedback").should be_false
      @supervision.step_finished?("providing_solutions").should be_false
      @supervision.step_finished?("giving_solutions_feedback").should be_false
      @supervision.step_finished?("giving_supervision_feedbacks").should be_false
      @supervision.step_finished?("finished").should be_false
    end

    it "should be correct for :ideas_feedback state" do
      @supervision.state = "giving_ideas_feedback"
      @supervision.step_finished?("gathering_topics").should be_true
      @supervision.step_finished?("voting_on_topics").should be_true
      @supervision.step_finished?("asking_questions").should be_true
      @supervision.step_finished?("providing_ideas").should be_true
      @supervision.step_finished?("giving_ideas_feedback").should be_false
      @supervision.step_finished?("providing_solutions").should be_false
      @supervision.step_finished?("giving_solutions_feedback").should be_false
      @supervision.step_finished?("giving_supervision_feedbacks").should be_false
      @supervision.step_finished?("finished").should be_false
    end

    it "should be correct for :solutions state" do
      @supervision.state = "providing_solutions"
      @supervision.step_finished?("gathering_topics").should be_true
      @supervision.step_finished?("voting_on_topics").should be_true
      @supervision.step_finished?("asking_questions").should be_true
      @supervision.step_finished?("providing_ideas").should be_true
      @supervision.step_finished?("giving_ideas_feedback").should be_true
      @supervision.step_finished?("providing_solutions").should be_false
      @supervision.step_finished?("giving_solutions_feedback").should be_false
      @supervision.step_finished?("giving_supervision_feedbacks").should be_false
      @supervision.step_finished?("finished").should be_false
    end

    it "should be correct for :solutions_feedback state" do
      @supervision.state = "giving_solutions_feedback"
      @supervision.step_finished?("gathering_topics").should be_true
      @supervision.step_finished?("voting_on_topics").should be_true
      @supervision.step_finished?("asking_questions").should be_true
      @supervision.step_finished?("providing_ideas").should be_true
      @supervision.step_finished?("giving_ideas_feedback").should be_true
      @supervision.step_finished?("providing_solutions").should be_true
      @supervision.step_finished?("giving_solutions_feedback").should be_false
      @supervision.step_finished?("giving_supervision_feedbacks").should be_false
      @supervision.step_finished?("finished").should be_false
    end

    it "should be correct for :supervision_feedbacks state" do
      @supervision.state = "giving_supervision_feedbacks"
      @supervision.step_finished?("gathering_topics").should be_true
      @supervision.step_finished?("voting_on_topics").should be_true
      @supervision.step_finished?("asking_questions").should be_true
      @supervision.step_finished?("providing_ideas").should be_true
      @supervision.step_finished?("giving_ideas_feedback").should be_true
      @supervision.step_finished?("providing_solutions").should be_true
      @supervision.step_finished?("giving_solutions_feedback").should be_true
      @supervision.step_finished?("giving_supervision_feedbacks").should be_false
      @supervision.step_finished?("finished").should be_false
    end

    it "should be correct for :finished state" do
      @supervision.state = "finished"
      @supervision.step_finished?("gathering_topics").should be_true
      @supervision.step_finished?("voting_on_topics").should be_true
      @supervision.step_finished?("asking_questions").should be_true
      @supervision.step_finished?("providing_ideas").should be_true
      @supervision.step_finished?("giving_ideas_feedback").should be_true
      @supervision.step_finished?("providing_solutions").should be_true
      @supervision.step_finished?("giving_solutions_feedback").should be_true
      @supervision.step_finished?("giving_supervision_feedbacks").should be_true
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

  it "should include SupervisionRedisPublisher module" do
    included_modules = Supervision.send :included_modules
    included_modules.should include(SupervisionRedisPublisher)
  end

  describe "#supervision_publish_attributed" do
    it "should have only known options" do
      @answer = Supervision.new
      @answer.supervision_publish_attributes.should be == {:only => [:id, :state, :topic_id]}
    end
  end
end

