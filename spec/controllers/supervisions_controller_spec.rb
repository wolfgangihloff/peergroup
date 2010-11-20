require 'spec_helper'

describe SupervisionsController do

  before do
    @group = Factory(:group)
    @founder = @group.founder
    test_sign_in(@founder)
  end

  def mock_current_supervision_with(supervision)
    Group.should_receive(:find).with(@group.id).and_return(@group)
    @group.should_receive(:current_supervision).and_return(supervision)
  end

  describe "new" do
    context "when current supervision already exists" do
      before { mock_current_supervision_with(@supervision = @group.supervisions.create!) }

      it "should redirect to show current supervision" do
        controller.should_receive(:supervision_step_path).with(@supervision).and_return("/path")
        get :new, :group_id => @group.id
        response.should redirect_to("/path")
      end
    end

    context "when no current supervision" do
      before { mock_current_supervision_with(nil) }

      it "should display new supervision question" do
        get :new, :group_id => @group.id
        response.should render_template("new")
      end
    end
  end

  describe "create" do

    context "when supervision already exists" do
      before do
        mock_current_supervision_with(@supervision = @group.supervisions.create!)
        controller.should_receive(:supervision_step_path).with(@supervision).and_return("/path")
        post :create, :group_id => @group.id
      end

      specify { response.should redirect_to("/path") }
      specify { @group.supervisions.count.should == 1 }
    end

    context "when no current supervision" do
      before do
        mock_current_supervision_with(nil)
        controller.should_receive(:supervision_step_path).and_return("/path")
        post :create, :group_id => @group.id
        @current_supervision = @group.supervisions.first
      end

      specify { @current_supervision.should_not be_nil }
      specify { response.should redirect_to("/path") }
    end
  end

  describe "show" do
    context "when in choose topic state" do
      before do
        @supervision = @group.supervisions.create!(:state => "topic")
        get :show, :id => @supervision.id
      end

      specify { response.should be_success }
    end
  end
end

