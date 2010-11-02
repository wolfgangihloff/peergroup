require 'spec_helper'

describe ChatUpdate do

  it "should create a new instance given valid attributes" do
    Factory(:chat_update)
  end

  describe "newer_than scope" do
    before do
      outdated = past_chat_update(:updated_at => 2.seconds.ago)

      @current_time = Time.now
      @valid_update = Factory(:chat_update)
    end

    it "should return all updates updated after the given date" do
      ChatUpdate.newer_than(@current_time).all.should == [@valid_update]
    end
  end

  describe "not_new scope" do
    before do
      @new = Factory(:chat_update)
      @uncommited = Factory(:chat_update, :state => "uncommited")
      @commited = Factory(:chat_update, :state => "commited")
    end

    it "should return only commited and uncommited updates" do
      ChatUpdate.not_new.all.should =~ [@uncommited, @commited]
    end
  end

  describe "commit_message!" do
    before do
      @chat_update = Factory(:chat_update)
      @message = "Hi, it's new message"
    end

    def commited_update
      @chat_update.commit_message!(@message)
      @chat_update.reload
    end

    specify { commited_update.state.should == "commited" }
    specify { commited_update.message.should == @message }

    context "when chat room not in the problem rule" do
      before { @chat_update.should_receive(:chat_room).and_return(mock(:problem_rule? => false)) }

      specify { commited_update.writeboard.should be_nil }
    end

    context "when chat room in the problem rule" do
      before { @chat_update.should_receive(:chat_room).and_return(mock(:problem_rule? => true)) }

      specify { commited_update.writeboard.should == "problem" }
    end
  end

  describe "update_message!" do
    before do
      @message = "Hi"
      @timestamp = 5.minutes.ago
      @chat_update = past_chat_update(:message => @message, :updated_at => @timestamp)
    end

    it "should not touch the timestamp when message not changed" do
      @chat_update.update_message!(@message)
      @chat_update.updated_at.should be_close(@timestamp, 1.second)
    end

    describe "when message changed" do
      it "should save new message" do
        @chat_update.update_message!("Hi Tom")
        @chat_update.reload.message.should == "Hi Tom"
      end

      it "should mark the record as uncommited" do
        @chat_update.update_message!("Hi Tom")
        @chat_update.reload.state.should == "uncommited"
      end
    end
  end

  describe "message_updated_at" do
    before do
      @chat_update = past_chat_update(:message_updated_at => 1.hour.ago)
    end

    it "should be modified after message has been changed" do
      @chat_update.update_attributes!(:message => "Changed message")
      @chat_update.reload.message_updated_at.should > 1.minute.ago
    end

    it "should not be modified after message has not been changed" do
      @chat_update.update_attributes!(:state => :commited)
      @chat_update.reload.message_updated_at.should < 50.minutes.ago
    end
  end

  it "should be in new state after creating" do
    chat_update = Factory(:chat_update)
    chat_update.reload.state.should == "new"
  end

  it "should touch parent after updating" do
    parent_update = past_chat_update(:updated_at => 1.hour.ago)
    child_update = Factory(:chat_update, :parent_id => parent_update.id)

    child_update.update_attributes(:message => "new message")
    parent_update.reload.updated_at.should > 1.second.ago
  end

end

