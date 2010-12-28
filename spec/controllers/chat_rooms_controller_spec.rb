require "spec_helper"
require "rspec/mocks"

describe ChatRoomsController do

  before do
    @user = Factory(:user, :id => 1)
    @group = Factory(:group, :founder => @user)
    test_sign_in(@user)
  end

  describe "#show" do
    render_views

    before do
      @chat_room = @group.chat_room
      SecureRandom.should_receive(:hex).and_return("asdfb")
      REDIS.should_receive(:setex).with("chat:#{@chat_room.id}:users:1:token:asdfb", 60, "1")
      get :show, :group_id => @group.id, :id => @chat_room
    end

    specify { response.should be_success }
    # I know it sucks, but I don't know how to check for tag attribute with RSpec
    specify { assert_tag :tag => "div", :attributes => { "class" => "chat_room", "id" => "chat_room_#{@chat_room.id}", "data-token" => "asdfb" } }
  end
end
