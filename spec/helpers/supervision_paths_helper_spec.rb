require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the SupervisionPathsHelper. For example:
#
# describe SupervisionPathsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe SupervisionPathsHelper do

  describe "supervision_step_path" do

    def returned_path
      supervision_step_path(@supervision)
    end

    before do
      @supervision = Factory(:supervision)
      @user = @supervision.group.founder
      stub!(:current_user).and_return(@user)
    end

    context "when supervision is in topic state" do
      before { @supervision.should_receive(:state).and_return("topic") }

      context "and user has not yet submitted his topic" do
        specify { returned_path.should == new_topic_path(:supervision_id => @supervision.id) }
      end

      context "and user already submitted his topic" do
        before { @supervision.topics.create!(:user => @user) }

        specify { returned_path.should == topics_path(:supervision_id => @supervision.id) }
      end
    end

    context "when supervision is in topic_vote state" do
      before { @supervision.should_receive(:state).and_return("topic_vote") }

      context "when user not yet voted" do
        before { @supervision.should_receive(:voted_on_topic?).and_return(false) }

        specify { returned_path.should == new_topic_vote_path(:supervision_id => @supervision.id) }
      end

      context "when user already voted" do
        before { @supervision.should_receive(:voted_on_topic?).and_return(true) }

        specify { returned_path.should == topic_votes_path(:supervision_id => @supervision.id) }
      end
    end

    context "when supervision is in topic_question state" do
      before { @supervision.should_receive(:state).and_return("topic_question") }

      specify { returned_path.should == new_topic_question_path(:supervision_id => @supervision.id) }
    end

    context "when supervision is in idea state" do
      before { @supervision.should_receive(:state).and_return("idea") }

      specify { returned_path.should == ideas_path(:supervision_id => @supervision.id) }
    end

    context "when supervision is in idea_feedback state" do
      before { @supervision.should_receive(:state).and_return("idea_feedback") }

      specify { returned_path.should == ideas_path(:supervision_id => @supervision.id) }
    end
  end
end

