require 'spec_helper'

describe ChatUpdatesController do
  integrate_views

  before do
    @user = Factory(:user)
    test_sign_in(@user)
  end

  describe "update" do
    describe "when commiting" do
      before do
        @chat_update = Factory(:chat_update)
        @message = "Hi Kacper"
        put "update", :update_type => "commit",
          :chat_room_id => @chat_update.chat_room_id,
          :id => @chat_update.id,
          :chat_update => {:message => @message}
      end

      it "should be successful" do
        response.should be_success
      end

      it "should save chat update as commited" do
        @chat_update.reload.state.should == "commited"
      end

      it "should save chat update message" do
        @chat_update.reload.message.should == @message
      end

      it "should initialize new chat update" do
        assigns[:chat_update].state.should == "new"
      end

      it "should send chat update form to the browser" do
        response.should render_template("chat_updates/_form")
      end
    end

    describe "when updating only" do
      before do
        @chat_room = Factory(:chat_room)
        @chat_update = Factory(:chat_update, :chat_room => @chat_room)
        @message = "Hi Kacper"
        @current_time = Time.now
        @update = lambda {|format|
          put "update", :update_type => "update",
            :chat_room_id => @chat_room.id,
            :id => @chat_update.id,
            :format => format,
            :last_update => 1.second.ago,
            :chat_update => {:message => @message} }
      end

      it "should be successful" do
        @update.call('html')
        response.should be_success
      end

      it "should perform the update" do
        ChatUpdate.should_receive(:find).and_return(@chat_update)
        @chat_update.should_receive(:update_message!).with(@message)
        @update.call('html')
      end

      describe "the response body" do
        before do
          @outdated_update = past_chat_update(:updated_at => 10.seconds.ago,
            :chat_room => @chat_room, :state => "commited")
          @child_update = Factory(:chat_update,
            :chat_room => @chat_room, :state => "commited")
          @child_update.attach_parent!(@chat_update.id)

          @update.call('json')
          @response = JSON.load(response.body)
        end

        describe "feeds array" do
          it "should contain missing updates" do
            @response["feeds"].first["update"].should =~ /#{@chat_update.reload.message}/
          end

          it "should contain ids of missing updates" do
            @response["feeds"].first["id"].should == "chat_update_#{@chat_update.id.to_s}"
          end

          it "should not contain child updates" do
            @response["feeds"].size.should == 1
          end
        end

        it "should send current timestamp" do
          @response["timestamp"].should >= Time.now.to_i - 1
        end
      end
    end
  end
end

