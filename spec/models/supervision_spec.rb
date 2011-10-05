require 'spec_helper'

describe Supervision do
  context "class" do
    describe "#finished" do
      it "should return only finished supervisions" do
        @supervision = FactoryGirl.create(:supervision)
        @finished_supervision = FactoryGirl.create(:supervision, :state => "finished")
        @cancelled_supervision = FactoryGirl.create(:supervision, :state => "cancelled")

        Supervision.finished.all.should == [@finished_supervision]
      end
    end

    describe "#in_progress" do
      it "should return only unfinished supervisions" do
        @supervision = FactoryGirl.create(:supervision)
        @finished_supervision = FactoryGirl.create(:supervision, :state => "finished")
        @cancelled_supervision = FactoryGirl.create(:supervision, :state => "cancelled")

        Supervision.in_progress.all.should == [@supervision]
      end
    end

    describe "#cancelled" do
      it "should return only cancelled supervisions" do
        @supervision = FactoryGirl.create(:supervision)
        @finished_supervision = FactoryGirl.create(:supervision, :state => "finished")
        @cancelled_supervision = FactoryGirl.create(:supervision, :state => "cancelled")

        Supervision.cancelled.all.should == [@cancelled_supervision]
      end
    end
  end

  describe "#voted_on_topic?" do
    it "should be true when user already voted on topic" do
      @supervision = FactoryGirl.create(:supervision)
      @topic = FactoryGirl.create(:topic, :supervision => @supervision)
      @user = @topic.user
      @topic.votes.create! do |vote|
        vote.user = @user
      end
      @supervision.voted_on_topic?(@user).should be_true
    end

    it "should be false when user not yet voted on topic" do
      @supervision = FactoryGirl.create(:supervision)
      @user = @supervision.group.founder
      @supervision.voted_on_topic?(@user).should be_false
    end
  end

  describe "#step_finished?" do
    before do
      @supervision = FactoryGirl.build(:supervision)
    end
    it "should use Supervision::STEPS and it should be correct" do
      Supervision::STEPS.should == %w[
         waiting_for_members
         gathering_topics
         voting_on_topics
         asking_questions
         giving_answers
         providing_ideas
         voting_ideas
         giving_ideas_feedback
         providing_solutions
         voting_solutions
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
      @supervision = FactoryGirl.create(:supervision)
      @user = FactoryGirl.create(:user)
      @supervision.posted_topic?(@user).should be_false
    end

    it "should be false if user haven't posted topic" do
      @supervision = FactoryGirl.create(:supervision)
      @user = FactoryGirl.create(:user)
      @supervision.topics.create { |t| t.user,t.content = FactoryGirl.create(:user),"topic" }
      @supervision.posted_topic?(@user).should be_false
    end

    it "should be true if user posted topic" do
      @supervision = FactoryGirl.create(:supervision)
      @user = FactoryGirl.create(:user)
      @supervision.topics.create { |t| t.user,t.content = @user,"topic" }
      @supervision.posted_topic?(@user).should be_true
    end
  end

  describe "#voted_on_topic?" do
    it "should be false if no votes on topics" do
      @supervision = FactoryGirl.create(:supervision)
      @user = FactoryGirl.create(:user)
      @supervision.voted_on_topic?(@user).should be_false
    end

    it "should be false if user haven't voted" do
      @supervision = FactoryGirl.create(:supervision)
      @topic = FactoryGirl.create(:topic, :supervision => @supervision)
      @user = FactoryGirl.create(:user)
      @topic.votes.create { |v| v.user = FactoryGirl.create(:user) }
      @supervision.voted_on_topic?(@user).should be_false
    end

    it "should be true if user voted" do
      @supervision = FactoryGirl.create(:supervision)
      @topic = FactoryGirl.create(:topic, :supervision => @supervision)
      @user = FactoryGirl.create(:user)
      @topic.votes.create { |v| v.user = @user }
      @supervision.voted_on_topic?(@user).should be_true
    end
  end

  describe "#voted_on_next_step?" do
    it "should be false if no next state votes present" do
      @supervision = FactoryGirl.create(:supervision)
      @user = FactoryGirl.create(:user)
      @supervision.voted_on_next_step?(@user).should be_false
    end

    it "should be false if user haven't voted on next state" do
      @supervision = FactoryGirl.create(:supervision)
      @user = FactoryGirl.create(:user)
      @supervision.next_step_votes.create { |v| v.user = FactoryGirl.create(:user) }
      @supervision.voted_on_next_step?(@user).should be_false
    end

    it "should be true if user voted on next state" do
      @supervision = FactoryGirl.create(:supervision)
      @user = FactoryGirl.create(:user)
      @supervision.next_step_votes.create { |v| v.user = @user }
      @supervision.voted_on_next_step?(@user).should be_true
    end
  end

  describe "#posted_supervision_feedback?" do
    it "should be false when no supervision feedbacks present" do
      @supervision = FactoryGirl.create(:supervision)
      @user = FactoryGirl.create(:user)
      @supervision.posted_supervision_feedback?(@user).should be_false
    end

    it "should be false when user haven't posted feedback" do
      @supervision = FactoryGirl.create(:supervision)
      @user = FactoryGirl.create(:user)
      @feedback = FactoryGirl.create(:supervision_feedback, :supervision => @supervision)
      @supervision.posted_supervision_feedback?(@user).should be_false
    end

    it "should be true when user posted feedback" do
      @supervision = FactoryGirl.create(:supervision)
      @user = FactoryGirl.create(:user)
      @feedback = FactoryGirl.create(:supervision_feedback, :supervision => @supervision, :user => @user)
      @supervision.posted_supervision_feedback?(@user).should be_true
    end
  end

  describe "#problem_owner" do
    it "should be nil when no current topic" do
      @topic = FactoryGirl.build(:topic)
      @supervision = FactoryGirl.build(:supervision, :topic => nil)
      @supervision.topics << @topic
      @supervision.problem_owner.should be_nil
    end

    it "should be owner of topic" do
      @topic = FactoryGirl.build(:topic)
      @supervision = FactoryGirl.build(:supervision, :topic => @topic)
      @supervision.topics << @topic
      @supervision.problem_owner.should be == @topic.user
    end
  end

  describe "#problem_owner?" do
    it "should be false when no current topic" do
      @topic = FactoryGirl.build(:topic)
      @supervision = FactoryGirl.build(:supervision, :topic => nil)
      @supervision.topics << @topic
      @supervision.problem_owner?(@topic.user).should be_false
    end

    it "should be false if user is no author of current topic" do
      @topic = FactoryGirl.build(:topic)
      @another_topic = FactoryGirl.build(:topic)

      @supervision = FactoryGirl.build(:supervision, :topic => @topic)
      @supervision.topics << @topic
      @supervision.topics << @another_topic
      @supervision.problem_owner?(@another_topic.user).should be_false
    end

    it "should be true if user is author of current topic" do
      @topic = FactoryGirl.build(:topic)
      @another_topic = FactoryGirl.build(:topic)

      @supervision = FactoryGirl.build(:supervision, :topic => @topic)
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
      @supervision.send(:supervision_publish_attributes).should be == {:methods => :topic_user_id, :only => [:id, :state, :topic_id]}
    end
  end

  describe "state machine" do
    before do
      @alice = FactoryGirl.create(:user)
      @bob = FactoryGirl.create(:user)
      @cindy = FactoryGirl.create(:user)

      @group = FactoryGirl.create(:group, :founder => @alice)
      @group.add_member!(@bob)
      @group.add_member!(@cindy)
    end

    it "should be in waiting_for_members state after create" do
      @supervision = Supervision.new

      @supervision.waiting_for_members?.should be_true
    end

    it "should change from waiting_for_members to gathering_topics" do
      @supervision = FactoryGirl.create(:supervision, :group => @group, :state => "waiting_for_members")
      @bob.join_supervision(@supervision)
      @alice.join_supervision(@supervision)
      
      @supervision.reload
      @supervision.waiting_for_members?.should be_false
      @supervision.gathering_topics?.should be_true
    end

    it "should change from gathering_topics to voting_on_topics" do
      @supervision = FactoryGirl.create(:supervision, :group => @group, :state => "gathering_topics")
      @bob.join_supervision(@supervision)
      @alice.join_supervision(@supervision)
      @cindy.join_supervision(@supervision)

      FactoryGirl.create(:topic, :user => @alice, :supervision => @supervision)
      FactoryGirl.create(:topic, :user => @bob, :supervision => @supervision)
      FactoryGirl.create(:topic, :user => @cindy, :supervision => @supervision)

      @supervision.reload
      @supervision.gathering_topics?.should be_false
      @supervision.voting_on_topics?.should be_true
    end

    it "should change from gathering_topics to asking_questions if there is only one votable topic" do
      @supervision = FactoryGirl.create(:supervision, :group => @group, :state => "gathering_topics")
      @bob.join_supervision(@supervision)
      @alice.join_supervision(@supervision)
      @cindy.join_supervision(@supervision)

      FactoryGirl.create(:topic, :user => @alice, :supervision => @supervision)
      FactoryGirl.create(:topic, :content => "", :user => @bob, :supervision => @supervision)
      FactoryGirl.create(:topic, :content => "", :user => @cindy, :supervision => @supervision)

      @supervision.reload
      @supervision.gathering_topics?.should be_false
      @supervision.asking_questions?.should be_true
      
    end
    it "should change from voting_on_topics to asking_questions" do
      @supervision = FactoryGirl.create(:supervision, :group => @group, :state => "gathering_topics")
      @bob.join_supervision(@supervision)
      @alice.join_supervision(@supervision)
      @cindy.join_supervision(@supervision)

      @alices_topic = FactoryGirl.create(:topic, :user => @alice, :supervision => @supervision)
      FactoryGirl.create(:topic, :user => @bob, :supervision => @supervision)
      FactoryGirl.create(:topic, :user => @cindy, :supervision => @supervision)
      # in this place supervision.voting_on_topics? should be true

      FactoryGirl.create(:vote, :statement => @alices_topic, :user => @alice)
      FactoryGirl.create(:vote, :statement => @alices_topic, :user => @bob)
      @supervision.reload
      @supervision.voting_on_topics?.should be_true

      FactoryGirl.create(:vote, :statement => @alices_topic, :user => @cindy)
      @supervision.reload
      @supervision.voting_on_topics?.should be_false
      @supervision.asking_questions?.should be_true
      @supervision.topic.should == @alices_topic
    end

    it "should change from asking_questions to giving_answers" do
      @supervision = FactoryGirl.build(:supervision, :state => "asking_questions")
      @supervision.topic = FactoryGirl.create(:topic, :user => @alice, :supervision => @supervision)
      @supervision.save
      @bob.join_supervision(@supervision)
      @cindy.join_supervision(@supervision)

      @bobs_question = FactoryGirl.create(:question, :user => @bob, :supervision => @supervision)
      @cindys_question = FactoryGirl.create(:question, :user => @cindy, :supervision => @supervision)
      FactoryGirl.create(:answer, :question => @bobs_question, :user => @alice)

      FactoryGirl.create(:supervision_vote, :statement => @supervision, :user => @bob)
      FactoryGirl.create(:supervision_vote, :statement => @supervision, :user => @cindy)
      @supervision.reload
      @supervision.asking_questions?.should be_false
      @supervision.giving_answers?.should be_true

      FactoryGirl.create(:answer, :question => @cindys_question, :user => @alice)
      @supervision.reload
      @supervision.giving_answers?.should be_false
    end

    it "should change from providing_ideas to voting_ideas" do
      @supervision = FactoryGirl.build(:supervision, :state => "providing_ideas")
      @supervision.topic = FactoryGirl.create(:topic, :user => @alice, :supervision => @supervision)
      @supervision.save
      @bob.join_supervision(@supervision)
      @cindy.join_supervision(@supervision)

      @bobs_idea = FactoryGirl.create(:idea, :user => @bob, :supervision => @supervision)
      @cindys_idea = FactoryGirl.create(:idea, :user => @cindy, :supervision => @supervision)
      @bobs_idea.update_attributes({ :rating => 5 })

      FactoryGirl.create(:supervision_vote, :statement => @supervision, :user => @bob)
      FactoryGirl.create(:supervision_vote, :statement => @supervision, :user => @cindy)
      @supervision.reload
      @supervision.providing_ideas?.should be_false
      @supervision.voting_ideas?.should be_true

      @cindys_idea.update_attributes({ :rating => 3 })
      @supervision.reload
      @supervision.voting_ideas?.should be_false
      @supervision.giving_ideas_feedback?.should be_true
    end

    it "should change from giving_ideas_feedback to providing_solutions" do
      @supervision = FactoryGirl.build(:supervision, :state => "giving_ideas_feedback")
      @supervision.topic = FactoryGirl.create(:topic, :user => @alice, :supervision => @supervision)
      @supervision.save
      @bob.join_supervision(@supervision)
      @cindy.join_supervision(@supervision)

      FactoryGirl.create(:ideas_feedback, :user => @alice, :supervision => @supervision)
      @supervision.reload
      @supervision.providing_solutions?.should be_true
    end

    it "should change from providing_solutions to voting_solutions" do
      @supervision = FactoryGirl.build(:supervision, :state => "providing_solutions")
      @supervision.topic = FactoryGirl.create(:topic, :user => @alice, :supervision => @supervision)
      @supervision.save
      @bob.join_supervision(@supervision)
      @cindy.join_supervision(@supervision)

      @bobs_solution = FactoryGirl.create(:solution, :user => @bob, :supervision => @supervision)
      @cindys_solution = FactoryGirl.create(:solution, :user => @cindy, :supervision => @supervision)
      @bobs_solution.update_attributes({ :rating => 5 })

      FactoryGirl.create(:supervision_vote, :statement => @supervision, :user => @bob)
      FactoryGirl.create(:supervision_vote, :statement => @supervision, :user => @cindy)
      @supervision.reload
      @supervision.providing_solutions?.should be_false
      @supervision.voting_solutions?.should be_true

      @cindys_solution.update_attributes({ :rating => 3 })
      @supervision.reload
      @supervision.voting_solutions?.should be_false
      @supervision.giving_solutions_feedback?.should be_true
    end

    it "should change from giving_solutions_feedback to giving_supervision_feedbacks" do
      @supervision = FactoryGirl.build(:supervision, :state => "giving_solutions_feedback")
      @supervision.topic = FactoryGirl.create(:topic, :user => @alice, :supervision => @supervision)
      @supervision.save
      @bob.join_supervision(@supervision)
      @cindy.join_supervision(@supervision)

      FactoryGirl.create(:solutions_feedback, :user => @alice, :supervision => @supervision)
      @supervision.reload
      @supervision.giving_supervision_feedbacks?.should be_true
    end

    it "should change from giving_supervision_feedbacks to finished" do
      @supervision = FactoryGirl.build(:supervision, :state => "giving_supervision_feedbacks")
      @supervision.topic = FactoryGirl.create(:topic, :user => @alice, :supervision => @supervision)
      @supervision.save
      @bob.join_supervision(@supervision)
      @cindy.join_supervision(@supervision)

      FactoryGirl.create(:supervision_feedback, :user => @alice, :supervision => @supervision)
      FactoryGirl.create(:supervision_feedback, :user => @bob, :supervision => @supervision)
      @supervision.reload
      @supervision.giving_supervision_feedbacks?.should be_true

      FactoryGirl.create(:supervision_feedback, :user => @cindy, :supervision => @supervision)
      @supervision.reload
      @supervision.giving_supervision_feedbacks?.should be_false
      @supervision.finished?.should be_true
    end

    describe "step back to asking_questions" do
      it "should be allowed from providing_ideas" do
        @supervision = FactoryGirl.build(:supervision, :state => "providing_ideas")
        @bob.join_supervision(@supervision)
        @alice.join_supervision(@supervision)
        @supervision.should_receive(:publish_to_redis)
        @supervision.step_back_to_asking_questions!

        @supervision.asking_questions?.should be_true
      end

      it "should be allowed from giving_ideas_feedback" do
        @supervision = FactoryGirl.build(:supervision, :state => "giving_ideas_feedback")
        @bob.join_supervision(@supervision)
        @alice.join_supervision(@supervision)
        @supervision.should_receive(:publish_to_redis)
        @supervision.step_back_to_asking_questions!

        @supervision.asking_questions?.should be_true
      end

      it "should be allowed from providing_solutions" do
        @supervision = FactoryGirl.build(:supervision, :state => "providing_solutions")
        @bob.join_supervision(@supervision)
        @alice.join_supervision(@supervision)
        @supervision.should_receive(:publish_to_redis)
        @supervision.step_back_to_asking_questions!

        @supervision.asking_questions?.should be_true
      end

      it "should be allowed from giving_solutions_feedback" do
        @supervision = FactoryGirl.build(:supervision, :state => "giving_solutions_feedback")
        @bob.join_supervision(@supervision)
        @alice.join_supervision(@supervision)
        @supervision.should_receive(:publish_to_redis)
        @supervision.step_back_to_asking_questions!

        @supervision.asking_questions?.should be_true
      end

      it "should be allowed from giving_supervision_feedbacks" do
        @supervision = FactoryGirl.build(:supervision, :state => "giving_supervision_feedbacks")
        @bob.join_supervision(@supervision)
        @alice.join_supervision(@supervision)
        @supervision.should_receive(:publish_to_redis)
        @supervision.step_back_to_asking_questions!

        @supervision.asking_questions?.should be_true
      end
    end

    describe "step back to providing_ideas" do
      it "should be allowed from giving_ideas_feedback" do
        @supervision = FactoryGirl.build(:supervision, :state => "giving_ideas_feedback")
        @bob.join_supervision(@supervision)
        @alice.join_supervision(@supervision)
        @supervision.should_receive(:publish_to_redis)
        @supervision.step_back_to_providing_ideas!

        @supervision.providing_ideas?.should be_true
      end

      it "should be allowed from providing_solutions" do
        @supervision = FactoryGirl.build(:supervision, :state => "providing_solutions")
        @bob.join_supervision(@supervision)
        @alice.join_supervision(@supervision)
        @supervision.should_receive(:publish_to_redis)
        @supervision.step_back_to_providing_ideas!

        @supervision.providing_ideas?.should be_true
      end

      it "should be allowed from giving_solutions_feedback" do
        @supervision = FactoryGirl.build(:supervision, :state => "giving_solutions_feedback")
        @bob.join_supervision(@supervision)
        @alice.join_supervision(@supervision)
        @supervision.should_receive(:publish_to_redis)
        @supervision.step_back_to_providing_ideas!

        @supervision.providing_ideas?.should be_true
      end

      it "should be allowed from giving_supervision_feedbacks" do
        @supervision = FactoryGirl.build(:supervision, :state => "giving_supervision_feedbacks")
        @bob.join_supervision(@supervision)
        @alice.join_supervision(@supervision)
        @supervision.should_receive(:publish_to_redis)
        @supervision.step_back_to_providing_ideas!

        @supervision.providing_ideas?.should be_true
      end
    end

    describe "step back to giving_ideas_feedback" do
      it "should be allowed from providing_solutions" do
        @supervision = FactoryGirl.build(:supervision, :state => "providing_solutions")
        @bob.join_supervision(@supervision)
        @alice.join_supervision(@supervision)
        @supervision.should_receive(:publish_to_redis)
        @supervision.step_back_to_giving_ideas_feedback!

        @supervision.giving_ideas_feedback?.should be_true
      end

      it "should be allowed from giving_solutions_feedback" do
        @supervision = FactoryGirl.build(:supervision, :state => "giving_solutions_feedback")
        @bob.join_supervision(@supervision)
        @alice.join_supervision(@supervision)
        @supervision.should_receive(:publish_to_redis)
        @supervision.step_back_to_giving_ideas_feedback!

        @supervision.giving_ideas_feedback?.should be_true
      end

      it "should be allowed from giving_supervision_feedbacks" do
        @supervision = FactoryGirl.build(:supervision, :state => "giving_supervision_feedbacks")
        @bob.join_supervision(@supervision)
        @alice.join_supervision(@supervision)
        @supervision.should_receive(:publish_to_redis)
        @supervision.step_back_to_giving_ideas_feedback!

        @supervision.giving_ideas_feedback?.should be_true
      end
    end

    describe "step back to providing_solutions" do
      it "should be allowed from giving_solutions_feedback" do
        @supervision = FactoryGirl.build(:supervision, :state => "giving_solutions_feedback")
        @bob.join_supervision(@supervision)
        @alice.join_supervision(@supervision)
        @supervision.should_receive(:publish_to_redis)
        @supervision.step_back_to_providing_solutions!

        @supervision.providing_solutions?.should be_true
      end

      it "should be allowed from giving_supervision_feedbacks" do
        @supervision = FactoryGirl.build(:supervision, :state => "giving_supervision_feedbacks")
        @bob.join_supervision(@supervision)
        @alice.join_supervision(@supervision)
        @supervision.should_receive(:publish_to_redis)
        @supervision.step_back_to_providing_solutions!

        @supervision.providing_solutions?.should be_true
      end
    end

    describe "step back to giving_solutions_feedback" do
      it "should be allowed from giving_supervision_feedbacks" do
        @supervision = FactoryGirl.build(:supervision, :state => "giving_supervision_feedbacks")
        @bob.join_supervision(@supervision)
        @alice.join_supervision(@supervision)
        @supervision.should_receive(:publish_to_redis)
        @supervision.step_back_to_giving_solutions_feedback!

        @supervision.giving_solutions_feedback?.should be_true
      end
    end

    describe "#remove_member" do
      before do
        @alice = FactoryGirl.create(:user)
        @bob = FactoryGirl.create(:user)
        @cindy = FactoryGirl.create(:user)
      end

      it "should not change state if it's not needed" do
        @supervision = FactoryGirl.create(:supervision, :state => "giving_supervision_feedbacks")
        @bob.join_supervision(@supervision)
        @cindy.join_supervision(@supervision)
        @alice.join_supervision(@supervision)

        @supervision.topic = FactoryGirl.create(:topic, :supervision => @supervision, :user => @alice)
        @supervision.save

        @bob.leave_supervision(@supervision)

        @supervision.reload
        @supervision.giving_supervision_feedbacks?.should be_true
      end

      it "should change to cancelled state if there is only topic owner left" do
        @supervision = FactoryGirl.create(:supervision, :state => "giving_supervision_feedbacks")
        @supervision.topic = FactoryGirl.create(:topic, :supervision => @supervision, :user => @alice)
        @supervision.save
        @bob.join_supervision(@supervision)

        @bob.leave_supervision(@supervision)

        @supervision.reload
        @supervision.cancelled?.should be_true
      end

      it "should change to cancelled state if topic owner leaves" do
        @supervision = FactoryGirl.create(:supervision, :state => "giving_supervision_feedbacks")
        @alice.join_supervision(@supervision)
        @bob.join_supervision(@supervision)
        @cindy.join_supervision(@supervision)

        @supervision.topic = FactoryGirl.create(:topic, :supervision => @supervision, :user => @alice)
        @supervision.save

        @alice.leave_supervision(@supervision)

        @supervision.reload
        @supervision.cancelled?.should be_true
      end

      it "should change to next state if last member leaves" do
        @supervision = FactoryGirl.create(:supervision, :state => "giving_supervision_feedbacks")

        @alice.join_supervision(@supervision)
        @bob.join_supervision(@supervision)
        @cindy.join_supervision(@supervision)

        @supervision.topic = FactoryGirl.create(:topic, :supervision => @supervision, :user => @alice)
        @supervision.save

        @supervision.supervision_feedbacks << FactoryGirl.create(:supervision_feedback, :supervision => @supervision, :user => @alice)
        @supervision.supervision_feedbacks << FactoryGirl.create(:supervision_feedback, :supervision => @supervision, :user => @bob)
        @cindy.leave_supervision(@supervision)

        @supervision.reload
        @supervision.finished?.should be_true
      end
    end
  end

  describe "state_event attribute" do
   before do
      @alice = FactoryGirl.create(:user)
      @bob = FactoryGirl.create(:user)
    end

    it "should be accessible to mass assignment" do
      @supervision = FactoryGirl.create(:supervision, :state => "providing_ideas")
      @bob.join_supervision(@supervision)
      @alice.join_supervision(@supervision)
      @supervision.update_attributes({:state_event => "step_back_to_asking_questions"})
      @supervision.state.should == "asking_questions"
      @supervision.asking_questions?.should be_true
    end
  end
end
