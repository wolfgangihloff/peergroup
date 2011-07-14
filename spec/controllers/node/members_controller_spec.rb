require "spec_helper"

describe Node::MembersController do
  before do
    @user = FactoryGirl.create(:user)
    @group = FactoryGirl.create(:group)
    @group.add_member!(@user)
    @supervision = FactoryGirl.create(:supervision, :group => @group)
    @user.join_supervision(@supervision)
  end

  it "should remove member from given supervision" do
    login_node
    delete :destroy, :supervision_id => @supervision, :id => @user, :format => :json
    response.code.should == "200"
    @supervision.members.reload.exists?(@user).should be_false
  end

  it "should not allow to remove member from supervision without authorization" do
    delete :destroy, :supervision_id => @supervision, :id => @user, :format => :json
    response.code.should == "401"
    @supervision.members.reload.exists?(@user).should be_true
  end
end
