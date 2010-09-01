require 'spec_helper'

describe ChatUpdate do
  it "should create a new instance given valid attributes" do
    Factory(:chat_update)
  end

  describe "newer_than scope" do
    before do
      Factory(:chat_update, :created_at => 1.second.ago)
      @current_time = Time.now
      @valid_update = Factory(:chat_update)
    end

    it "should return all updates newer than given date" do
      ChatUpdate.newer_than(@current_time).all.should == [@valid_update]
    end
  end
end

