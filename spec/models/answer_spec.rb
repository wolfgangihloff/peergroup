require "spec_helper"

describe Answer do
  it "should crate a new instance given valid attributes" do
    Factory.build(:answer).valid?.should be_true
  end

  describe "user attribute" do
    it "should be required" do
      @answer = Factory.build(:answer, :user => nil)
      @answer.valid?.should be_false
      @answer.should have(1).error_on(:user)
    end

    it "should be protected agains mass assignment" do
      @user = Factory.build(:user)
      @answer = Factory.build(:answer, :user => @user)
      @another_user = Factory.build(:user)

      @answer.attributes = { :user => @another_user }
      @answer.user.should be == @user
    end
  end

  describe "question attribute" do
    it "should be required" do
      @answer = Factory.build(:answer, :question => nil, :user => Factory.build(:user))
      @answer.valid?.should be_false
      @answer.should have(1).error_on(:question)
    end

    it "should be protected agains mass assignment" do
      @question = Factory.build(:question)
      @answer = Factory.build(:answer, :question => @question)
      @another_question = Factory.build(:question)

      @answer.attributes = { :question => @another_question }
      @answer.question.should be == @question
    end
  end

  describe "content attribute" do
    it "should be required" do
      @answer = Factory.build(:answer, :content => nil)
      @answer.valid?.should be_false
      @answer.should have(1).error_on(:content)
    end

    it "should be accessible to mass assignment" do
      @answer = Factory.build(:answer, :content => "Simple content")
      @answer.attributes = { :content => "Another content" }
      @answer.content.should be == "Another content"
    end
  end

  describe "supervision attribute" do
    it "shuld delegate to question" do
      @question = Factory.build(:question)
      @answer = Factory.build(:answer, :question => @question)
      @question.should_receive(:supervision).and_return("supervision")
      @answer.supervision.should be == "supervision"
    end
  end

  describe "after create" do
    it "should notify supervision with #post_vote_for_next_step" do
      @supervision = Factory(:supervision)
      @question = Factory(:question, :supervision => @supervision)
      @answer = Factory.build(:answer, :question => @question)
      @supervision.should_receive(:post_vote_for_next_step).with(@answer)
      @answer.save!
    end
  end
end

