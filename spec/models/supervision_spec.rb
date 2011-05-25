$:.unshift File.join(File.dirname(__FILE__), "..")
require 'spec_helper'

describe Supervision do
  context "class" do
    describe "#finished" do
      it "should return only finished supervisions" do
        @supervision = Factory(:supervision)
        @finished_supervision = Factory(:supervision, :state => "finished")
        @cancelled_supervision = Factory(:supervision, :state => "cancelled")

        Supervision.finished.all.should be == [@finished_supervision]
      end
    end

    describe "#in_progress" do
      it "should return only unfinished supervisions" do
        @supervision = Factory(:supervision)
        @finished_supervision = Factory(:supervision, :state => "finished")
        @cancelled_supervision = Factory(:supervision, :state => "cancelled")

        Supervision.in_progress.all.should be == [@supervision]
      end
    end

    describe "#cancelled" do
      it "should return only cancelled supervisions" do
        @supervision = Factory(:supervision)
        @finished_supervision = Factory(:supervision, :state => "finished")
        @cancelled_supervision = Factory(:supervision, :state => "cancelled")

        Supervision.cancelled.all.should be == [@cancelled_supervision]
      end
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

  describe "#step_finished?" do
    before do
      @supervision = Factory.build(:supervision)
    end
    it "should use Supervision::STEPS and it should be correct" do
      Supervision::STEPS.should == %w[
         gathering_topics
         voting_on_topics
         asking_questions
         providing_ideas
         giving_ideas_feedback
         providing_solutions
         giving_solutions_feedback
         giving_supervision_feedbacks
       ]
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
    end

    it "should always be true for :finished state" do
      @supervision.state = "finished"
      @supervision.step_finished?("gathering_topics").should be_true
      @supervision.step_finished?("voting_on_topics").should be_true
      @supervision.step_finished?("asking_questions").should be_true
      @supervision.step_finished?("providing_ideas").should be_true
      @supervision.step_finished?("giving_ideas_feedback").should be_true
      @supervision.step_finished?("providing_solutions").should be_true
      @supervision.step_finished?("giving_solutions_feedback").should be_true
      @supervision.step_finished?("giving_supervision_feedbacks").should be_true
    end

    it "should always be false for :cancelled state" do
      @supervision.state = "cancelled"
      @supervision.step_finished?("gathering_topics").should be_true
      @supervision.step_finished?("voting_on_topics").should be_true
      @supervision.step_finished?("asking_questions").should be_true
      @supervision.step_finished?("providing_ideas").should be_true
      @supervision.step_finished?("giving_ideas_feedback").should be_true
      @supervision.step_finished?("providing_solutions").should be_true
      @supervision.step_finished?("giving_solutions_feedback").should be_true
      @supervision.step_finished?("giving_supervision_feedbacks").should be_true
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
    it "should be false if no next state votes present" do
      @supervision = Factory(:supervision)
      @user = Factory(:user)
      @supervision.voted_on_next_step?(@user).should be_false
    end

    it "should be false if user haven't voted on next state" do
      @supervision = Factory(:supervision)
      @user = Factory(:user)
      @supervision.next_step_votes.create { |v| v.user = Factory(:user) }
      @supervision.voted_on_next_step?(@user).should be_false
    end

    it "should be true if user voted on next state" do
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
      @supervision = Supervision.new
      @supervision.send(:supervision_publish_attributes).should be == {:only => [:id, :state, :topic_id]}
    end
  end

  describe "state machine" do
    before do
      @alice = Factory(:user)
      @bob = Factory(:user)
      @cindy = Factory(:user)

      @group = Factory(:group, :founder => @alice)
      @group.add_member!(@bob)
      @group.add_member!(@cindy)
    end

    it "should be in gathering_topics state after create" do
      @supervision = Supervision.new

      @supervision.gathering_topics?.should be_true
    end

    it "should change from gathering_topics to voting_on_topics" do
      @supervision = Factory(:supervision, :group => @group, :state => "gathering_topics")

      Factory(:topic, :user => @alice, :supervision => @supervision)
      Factory(:topic, :user => @bob, :supervision => @supervision)
      @supervision.reload
      @supervision.gathering_topics?.should be_true

      Factory(:topic, :user => @cindy, :supervision => @supervision)
      @supervision.reload
      @supervision.gathering_topics?.should be_false
      @supervision.voting_on_topics?.should be_true
    end

    it "should change from voting_on_topics to asking_questions" do
      @supervision = Factory(:supervision, :group => @group, :state => "gathering_topics")
      @alices_topic = Factory(:topic, :user => @alice, :supervision => @supervision)
      Factory(:topic, :user => @bob, :supervision => @supervision)
      Factory(:topic, :user => @cindy, :supervision => @supervision)
      # in this place supervision.voting_on_topics? should be true

      Factory(:vote, :statement => @alices_topic, :user => @alice)
      Factory(:vote, :statement => @alices_topic, :user => @bob)
      @supervision.reload
      @supervision.voting_on_topics?.should be_true

      Factory(:vote, :statement => @alices_topic, :user => @cindy)
      @supervision.reload
      @supervision.voting_on_topics?.should be_false
      @supervision.asking_questions?.should be_true
      @supervision.topic.should be == @alices_topic
    end

    it "should change from asking_questions to providing_ideas" do
      @supervision = Factory.build(:supervision, :state => "asking_questions")
      @supervision.topic = Factory(:topic, :user => @alice, :supervision => @supervision)
      @supervision.save
      @bob.join_supervision(@supervision)
      @cindy.join_supervision(@supervision)

      @bobs_question = Factory(:question, :user => @bob, :supervision => @supervision)
      @cindys_question = Factory(:question, :user => @cindy, :supervision => @supervision)
      Factory(:answer, :question => @bobs_question, :user => @alice)

      Factory(:supervision_vote, :statement => @supervision, :user => @bob)
      Factory(:supervision_vote, :statement => @supervision, :user => @cindy)
      @supervision.reload
      @supervision.asking_questions?.should be_true

      Factory(:answer, :question => @cindys_question, :user => @alice)
      @supervision.reload
      @supervision.asking_questions?.should be_false
      @supervision.providing_ideas?.should be_true
    end

    it "should change from providing_ideas to giving_ideas_feedback" do
      @supervision = Factory.build(:supervision, :state => "providing_ideas")
      @supervision.topic = Factory(:topic, :user => @alice, :supervision => @supervision)
      @supervision.save
      @bob.join_supervision(@supervision)
      @cindy.join_supervision(@supervision)

      @bobs_idea = Factory(:idea, :user => @bob, :supervision => @supervision)
      @cindys_idea = Factory(:idea, :user => @cindy, :supervision => @supervision)
      @bobs_idea.update_attributes({ :rating => 5 })

      Factory(:supervision_vote, :statement => @supervision, :user => @bob)
      Factory(:supervision_vote, :statement => @supervision, :user => @cindy)
      @supervision.reload
      @supervision.providing_ideas?.should be_true

      @cindys_idea.update_attributes({ :rating => 3 })
      @supervision.reload
      @supervision.providing_ideas?.should be_false
      @supervision.giving_ideas_feedback?.should be_true
    end

    it "should change from giving_ideas_feedback to providing_solutions" do
      @supervision = Factory.build(:supervision, :state => "giving_ideas_feedback")
      @supervision.topic = Factory(:topic, :user => @alice, :supervision => @supervision)
      @supervision.save
      @bob.join_supervision(@supervision)
      @cindy.join_supervision(@supervision)

      Factory(:ideas_feedback, :user => @alice, :supervision => @supervision)
      @supervision.reload
      @supervision.providing_solutions?.should be_true
    end

    it "should change from providing_solutions to giving_solutions_feedback" do
      @supervision = Factory.build(:supervision, :state => "providing_solutions")
      @supervision.topic = Factory(:topic, :user => @alice, :supervision => @supervision)
      @supervision.save
      @bob.join_supervision(@supervision)
      @cindy.join_supervision(@supervision)

      @bobs_solution = Factory(:solution, :user => @bob, :supervision => @supervision)
      @cindys_solution = Factory(:solution, :user => @cindy, :supervision => @supervision)
      @bobs_solution.update_attributes({ :rating => 5 })

      Factory(:supervision_vote, :statement => @supervision, :user => @bob)
      Factory(:supervision_vote, :statement => @supervision, :user => @cindy)
      @supervision.reload
      @supervision.providing_solutions?.should be_true

      @cindys_solution.update_attributes({ :rating => 3 })
      @supervision.reload
      @supervision.providing_solutions?.should be_false
      @supervision.giving_solutions_feedback?.should be_true
    end

    it "should change from giving_solutions_feedback to giving_supervision_feedbacks" do
      @supervision = Factory.build(:supervision, :state => "giving_solutions_feedback")
      @supervision.topic = Factory(:topic, :user => @alice, :supervision => @supervision)
      @supervision.save
      @bob.join_supervision(@supervision)
      @cindy.join_supervision(@supervision)

      Factory(:solutions_feedback, :user => @alice, :supervision => @supervision)
      @supervision.reload
      @supervision.giving_supervision_feedbacks?.should be_true
    end

    it "should change from giving_supervision_feedbacks to finished" do
      @supervision = Factory.build(:supervision, :state => "giving_supervision_feedbacks")
      @supervision.topic = Factory(:topic, :user => @alice, :supervision => @supervision)
      @supervision.save
      @bob.join_supervision(@supervision)
      @cindy.join_supervision(@supervision)

      Factory(:supervision_feedback, :user => @alice, :supervision => @supervision)
      Factory(:supervision_feedback, :user => @bob, :supervision => @supervision)
      @supervision.reload
      @supervision.giving_supervision_feedbacks?.should be_true

      Factory(:supervision_feedback, :user => @cindy, :supervision => @supervision)
      @supervision.reload
      @supervision.giving_supervision_feedbacks?.should be_false
      @supervision.finished?.should be_true
    end

    describe "step back to asking_questions" do
      it "should be allowed from providing_ideas" do
        @supervision = Factory.build(:supervision, :state => "providing_ideas")

        @supervision.should_receive(:publish_to_redis)
        @supervision.step_back_to_asking_questions!

        @supervision.asking_questions?.should be_true
      end

      it "should be allowed from giving_ideas_feedback" do
        @supervision = Factory.build(:supervision, :state => "giving_ideas_feedback")

        @supervision.should_receive(:publish_to_redis)
        @supervision.step_back_to_asking_questions!

        @supervision.asking_questions?.should be_true
      end

      it "should be allowed from providing_solutions" do
        @supervision = Factory.build(:supervision, :state => "providing_solutions")

        @supervision.should_receive(:publish_to_redis)
        @supervision.step_back_to_asking_questions!

        @supervision.asking_questions?.should be_true
      end

      it "should be allowed from giving_solutions_feedback" do
        @supervision = Factory.build(:supervision, :state => "giving_solutions_feedback")

        @supervision.should_receive(:publish_to_redis)
        @supervision.step_back_to_asking_questions!

        @supervision.asking_questions?.should be_true
      end

      it "should be allowed from giving_supervision_feedbacks" do
        @supervision = Factory.build(:supervision, :state => "giving_supervision_feedbacks")

        @supervision.should_receive(:publish_to_redis)
        @supervision.step_back_to_asking_questions!

        @supervision.asking_questions?.should be_true
      end
    end

    describe "step back to providing_ideas" do
      it "should be allowed from giving_ideas_feedback" do
        @supervision = Factory.build(:supervision, :state => "giving_ideas_feedback")

        @supervision.should_receive(:publish_to_redis)
        @supervision.step_back_to_providing_ideas!

        @supervision.providing_ideas?.should be_true
      end

      it "should be allowed from providing_solutions" do
        @supervision = Factory.build(:supervision, :state => "providing_solutions")

        @supervision.should_receive(:publish_to_redis)
        @supervision.step_back_to_providing_ideas!

        @supervision.providing_ideas?.should be_true
      end

      it "should be allowed from giving_solutions_feedback" do
        @supervision = Factory.build(:supervision, :state => "giving_solutions_feedback")

        @supervision.should_receive(:publish_to_redis)
        @supervision.step_back_to_providing_ideas!

        @supervision.providing_ideas?.should be_true
      end

      it "should be allowed from giving_supervision_feedbacks" do
        @supervision = Factory.build(:supervision, :state => "giving_supervision_feedbacks")

        @supervision.should_receive(:publish_to_redis)
        @supervision.step_back_to_providing_ideas!

        @supervision.providing_ideas?.should be_true
      end
    end

    describe "step back to giving_ideas_feedback" do
      it "should be allowed from providing_solutions" do
        @supervision = Factory.build(:supervision, :state => "providing_solutions")

        @supervision.should_receive(:publish_to_redis)
        @supervision.step_back_to_giving_ideas_feedback!

        @supervision.giving_ideas_feedback?.should be_true
      end

      it "should be allowed from giving_solutions_feedback" do
        @supervision = Factory.build(:supervision, :state => "giving_solutions_feedback")

        @supervision.should_receive(:publish_to_redis)
        @supervision.step_back_to_giving_ideas_feedback!

        @supervision.giving_ideas_feedback?.should be_true
      end

      it "should be allowed from giving_supervision_feedbacks" do
        @supervision = Factory.build(:supervision, :state => "giving_supervision_feedbacks")

        @supervision.should_receive(:publish_to_redis)
        @supervision.step_back_to_giving_ideas_feedback!

        @supervision.giving_ideas_feedback?.should be_true
      end
    end

    describe "step back to providing_solutions" do
      it "should be allowed from giving_solutions_feedback" do
        @supervision = Factory.build(:supervision, :state => "giving_solutions_feedback")

        @supervision.should_receive(:publish_to_redis)
        @supervision.step_back_to_providing_solutions!

        @supervision.providing_solutions?.should be_true
      end

      it "should be allowed from giving_supervision_feedbacks" do
        @supervision = Factory.build(:supervision, :state => "giving_supervision_feedbacks")

        @supervision.should_receive(:publish_to_redis)
        @supervision.step_back_to_providing_solutions!

        @supervision.providing_solutions?.should be_true
      end
    end

    describe "step back to giving_solutions_feedback" do
      it "should be allowed from giving_supervision_feedbacks" do
        @supervision = Factory.build(:supervision, :state => "giving_supervision_feedbacks")

        @supervision.should_receive(:publish_to_redis)
        @supervision.step_back_to_giving_solutions_feedback!

        @supervision.giving_solutions_feedback?.should be_true
      end
    end

    describe "#join_member" do
      it "should not change state" do
        @supervision = Factory.build(:supervision, :state => "giving_supervision_feedbacks")

        @supervision.should_receive(:publish_to_redis)
        @supervision.join_member!

        @supervision.giving_supervision_feedbacks?.should be_true
      end
    end

    describe "#remove_member" do
      before do
        @alice = Factory(:user)
        @bob = Factory(:user)
        @cindy = Factory(:user)
      end

      it "should not change state if it's not needed" do
        @supervision = Factory(:supervision, :state => "giving_supervision_feedbacks")
        @supervision.topic = Factory(:topic, :supervision => @supervision, :user => @alice)
        @supervision.save
        @bob.join_supervision(@supervision)
        @cindy.join_supervision(@supervision)

        @bob.leave_supervision(@supervision)

        @supervision.reload
        @supervision.giving_supervision_feedbacks?.should be_true
      end

      it "should change to cancelled state if there is only topic owner left" do
        @supervision = Factory(:supervision, :state => "giving_supervision_feedbacks")
        @supervision.topic = Factory(:topic, :supervision => @supervision, :user => @alice)
        @supervision.save
        @bob.join_supervision(@supervision)

        @bob.leave_supervision(@supervision)

        @supervision.reload
        @supervision.cancelled?.should be_true
      end

      it "should change to cancelled state if topic owner leaves" do
        @supervision = Factory(:supervision, :state => "giving_supervision_feedbacks")
        @supervision.topic = Factory(:topic, :supervision => @supervision, :user => @alice)
        @supervision.save
        @bob.join_supervision(@supervision)
        @cindy.join_supervision(@supervision)

        @alice.leave_supervision(@supervision)

        @supervision.reload
        @supervision.cancelled?.should be_true
      end

      it "should change to next state if last member leaves" do
        @supervision = Factory(:supervision, :state => "giving_supervision_feedbacks")

        @supervision.topic = Factory(:topic, :supervision => @supervision, :user => @alice)
        @supervision.save
        @bob.join_supervision(@supervision)
        @cindy.join_supervision(@supervision)

        @supervision.supervision_feedbacks << Factory(:supervision_feedback, :supervision => @supervision, :user => @alice)
        @supervision.supervision_feedbacks << Factory(:supervision_feedback, :supervision => @supervision, :user => @bob)
        @cindy.leave_supervision(@supervision)

        @supervision.reload
        @supervision.finished?.should be_true
      end
    end
  end

  describe "state_event attribute" do
    it "should be accessible to mass assignment" do
      @supervision = Factory(:supervision, :state => "providing_ideas")
      @supervision.update_attributes({:state_event => "step_back_to_asking_questions"})
      @supervision.state.should be == "asking_questions"
      @supervision.asking_questions?.should be_true
    end
  end
end

