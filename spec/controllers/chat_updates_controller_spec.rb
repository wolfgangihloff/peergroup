require 'spec_helper'

describe ChatUpdatesController do
  integrate_views

  describe "index" do
    before do
      @outdated_update = Factory(:chat_update, :created_at => Time.now - 10.seconds)
      @current_time = Time.now
      @valid_update = Factory(:chat_update)

      get "index", :last_update => (@current_time - 1.second).to_i, :format => :json
      @response = JSON.load(response.body)
    end

    describe "feeds array" do
      it "should contain missing updates" do
        @response["feeds"].first["update"].should =~ /#{@valid_update.message}/
      end

      it "should contain ids of missing updates" do
        @response["feeds"].first["id"].should == "chat_update_#{@valid_update.id.to_s}"
      end
    end

    it "should send current timestamp" do
      @response["timestamp"].should >= Time.now.to_i - 1
    end
  end
end
