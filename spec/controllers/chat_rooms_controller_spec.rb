require "spec_helper"

describe ChatRoomsController do

  before do
    @user = Factory(:user, :id => 1)
    @group = Factory(:group, :founder => @user)
    sign_in(@user)
  end

  describe "#show" do
    render_views

    before do
      REDIS.stub(:setex)
      @chat_room = @group.chat_room
      get :show, :group_id => @group.id, :id => @chat_room
    end

    specify { response.should be_success }
  end
end
