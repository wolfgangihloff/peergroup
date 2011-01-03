require "spec_helper"

describe Idea do
  it "should crate a new instance given valid attributes" do
    Factory.build(:idea).valid?.should be_true
  end

  describe "user attribute" do
    it "should be required" do
      @idea = Factory.build(:idea, :user => nil)
      @idea.valid?.should be_false
      @idea.should have(1).error_on(:user)
    end

    it "should be protected agains mass assignment" do
      @user = Factory.build(:user)
      @idea = Factory.build(:idea, :user => @user)
      @another_user = Factory.build(:user)

      @idea.attributes = { :user => @another_user }
      @idea.user.should be == @user
    end
  end

  describe "superivion attribute" do
    it "should be required" do
      @idea = Factory.build(:idea, :supervision => nil, :user => Factory.build(:user))
      @idea.valid?.should be_false
      @idea.should have(1).error_on(:supervision)
    end

    it "should be protected agains mass assignment" do
      @supervision = Factory.build(:supervision)
      @idea = Factory.build(:idea, :supervision => @supervision)
      @another_question = Factory.build(:question)

      @idea.attributes = { :supervision => @another_supervision }
      @idea.supervision.should be == @supervision
    end
  end

  describe "content attribute" do
    it "should be required" do
      @idea = Factory.build(:idea, :content => nil)
      @idea.valid?.should be_false
      @idea.should have(1).error_on(:content)
    end

    it "should be accessible to mass assignment" do
      @idea = Factory.build(:idea, :content => "Simple content")
      @idea.attributes = { :content => "Another content" }
      @idea.content.should be == "Another content"
    end
  end

  describe "rating attribute" do
    it "should allow nil" do
      @idea = Factory.build(:idea, :rating => nil)
      @idea.valid?.should be_true
    end

    it "should be numerical" do
      @idea = Factory.build(:idea, :rating => 5)
      @idea.valid?.should be_true
    end

    it "should not allow for non numerical values" do
      @idea = Factory.build(:idea, :rating => "text")
      @idea.valid?.should be_false
      @idea.should have(2).error_on(:rating)
    end

    it "should not allow for not integer values" do
      @idea = Factory.build(:idea, :rating => 1.1)
      @idea.valid?.should be_false
      @idea.should have(1).error_on(:rating)
    end

    it "should not allow values less than 1" do
      @idea = Factory.build(:idea, :rating => 0)
      @idea.valid?.should be_false
      @idea.should have(1).error_on(:rating)
    end

    it "should not allow values greater than 5" do
      @idea = Factory.build(:idea, :rating => 6)
      @idea.valid?.should be_false
      @idea.should have(1).error_on(:rating)
    end
  end

  describe "after create" do
    it "should publish idea to Redis channel" do
      @idea = Factory.build(:idea)
      @idea.should_receive(:publish_to_redis)
      @idea.save!
    end
  end

  describe "after update" do
    it "should notify supervision with #post_vote_for_next_step" do
      @supervision = Factory(:supervision)
      @idea = Factory(:idea, :supervision => @supervision)
      @supervision.should_receive(:post_vote_for_next_step)
      @idea.update_attributes!(:rating => 5)
    end

    it "should publish rated idea to to Redis channel" do
      @idea = Factory.build(:idea)
      @idea.should_receive(:publish_to_redis)
      @idea.update_attributes!(:rating => 5)
    end
  end

  it "should include SupervisionRedisPublisher module" do
    included_modules = Idea.send :included_modules
    included_modules.should include(SupervisionRedisPublisher)
  end

  describe "#supervision_publish_attributed" do
    it "should have only known options" do
      @answer = Idea.new
      @answer.supervision_publish_attributes.should be == {:only => [:id, :content, :rating, :user_id]}
    end
  end
end
