require "spec_helper"

describe Question do
  it "should crate a new instance given valid attributes" do
    Factory.build(:question).valid?.should be_true
  end

  describe "user attribute" do
    it "should be required" do
      @question = Factory.build(:question, :user => nil)
      @question.valid?.should be_false
      @question.should have(1).error_on(:user)
    end

    it "should be protected agains mass assignment" do
      @user = Factory.build(:user)
      @question = Factory.build(:question, :user => @user)
      @another_user = Factory.build(:user)

      @question.attributes = { :user => @another_user }
      @question.user.should be == @user
    end
  end

  describe "supervision attribute" do
    it "should be required" do
      @question = Factory.build(:question, :supervision => nil, :user => Factory.build(:user))
      @question.valid?.should be_false
      @question.should have(1).error_on(:supervision)
    end

    it "should be protected agains mass assignment" do
      @supervision = Factory.build(:supervision)
      @question = Factory.build(:question, :supervision => @supervision)
      @another_supervision = Factory.build(:supervision)

      @question.attributes = { :supervision => @another_supervision }
      @question.supervision.should be == @supervision
    end
  end

  describe "content attribute" do
    it "should be required" do
      @question = Factory.build(:question, :content => nil)
      @question.valid?.should be_false
      @question.should have(1).error_on(:content)
    end

    it "should be accessible to mass assignment" do
      @question = Factory.build(:question, :content => "Simple content")
      @question.attributes = { :content => "Another content" }
      @question.content.should be == "Another content"
    end
  end

  describe "after create" do
    it "should notify supervision with #post_vote_for_next_step" do
      @supervision = Factory(:supervision)
      @question = Factory.build(:question, :supervision => @supervision)
      @supervision.should_receive(:post_question).with(@question)
      @question.save!
    end
  end
end
