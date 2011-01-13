$:.unshift File.join(File.dirname(__FILE__), "..", "..")
require "spec_helper"

describe Supervision do
  describe "state machine" do
    it "should be in gathering_topics state after create" do
      @supervision = Supervision.new

      @supervision.state.should == "gathering_topics"
      @supervision.gathering_topics?.should be_true
    end

    it "should change from gathering_topics to voting_on_topics" do
      @supervision = Factory.build(:supervision, :state => "gathering_topics")

      @supervision.should_receive(:all_topics?).and_return(true)
      @supervision.should_receive(:publish_to_redis)
      @supervision.post_topic!

      @supervision.state.should be == "voting_on_topics"
      @supervision.voting_on_topics?.should be_true
    end

    it "should change from voting_on_topics to asking_questions" do
      @supervision = Factory.build(:supervision, :state => "voting_on_topics")

      @supervision.should_receive(:all_topic_votes?).and_return(true)
      @supervision.should_receive(:choose_topic)
      @supervision.should_receive(:publish_to_redis)
      @supervision.post_topic_vote!

      @supervision.state.should be == "asking_questions"
      @supervision.asking_questions?.should be_true
    end

    it "should change from asking_questions to providing_ideas" do
      @supervision = Factory.build(:supervision, :state => "asking_questions")

      @supervision.should_receive(:all_answers?).and_return(true)
      @supervision.should_receive(:all_next_step_votes?).and_return(true)
      @supervision.should_receive(:publish_to_redis)
      @supervision.should_receive(:destroy_next_step_votes)
      @supervision.post_vote_for_next_step!

      @supervision.state.should be == "providing_ideas"
      @supervision.providing_ideas?.should be_true
    end

    it "should change from providing_ideas to giving_ideas_feedback" do
      @supervision = Factory.build(:supervision, :state => "providing_ideas")

      @supervision.should_receive(:all_idea_ratings?).and_return(true)
      @supervision.should_receive(:all_next_step_votes?).and_return(true)
      @supervision.should_receive(:publish_to_redis)
      @supervision.should_receive(:destroy_next_step_votes)
      @supervision.post_vote_for_next_step!

      @supervision.state.should be == "giving_ideas_feedback"
      @supervision.giving_ideas_feedback?.should be_true
    end

    it "should change from giving_ideas_feedback to providing_solutions" do
      @supervision = Factory.build(:supervision, :state => "giving_ideas_feedback")

      @supervision.post_ideas_feedback!

      @supervision.state.should be == "providing_solutions"
      @supervision.providing_solutions?.should be_true
    end

    it "should change from providing_solutions to giving_solutions_feedback" do
      @supervision = Factory.build(:supervision, :state => "providing_solutions")

      @supervision.should_receive(:all_solution_ratings?).and_return(true)
      @supervision.should_receive(:all_next_step_votes?).and_return(true)
      @supervision.should_receive(:publish_to_redis)
      @supervision.should_receive(:destroy_next_step_votes)
      @supervision.post_vote_for_next_step!

      @supervision.state.should be == "giving_solutions_feedback"
      @supervision.giving_solutions_feedback?.should be_true
    end

    it "should change from giving_solutions_feedback to giving_supervision_feedbacks" do
      @supervision = Factory.build(:supervision, :state => "giving_solutions_feedback")

      @supervision.should_receive(:publish_to_redis)
      @supervision.post_solutions_feedback!

      @supervision.state.should be == "giving_supervision_feedbacks"
      @supervision.giving_supervision_feedbacks?.should be_true
    end

    it "should change from giving_supervision_feedbacks to finished" do
      @supervision = Factory.build(:supervision, :state => "giving_supervision_feedbacks")

      @supervision.should_receive(:all_supervision_feedbacks?).and_return(true)
      @supervision.should_receive(:publish_to_redis)
      @supervision.post_supervision_feedback!

      @supervision.state.should be == "finished"
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
  end
end
