require "spec_helper"

describe Solution do
  it "should crate a new instance given valid attributes" do
    Factory.build(:solution).valid?.should be_true
  end

  describe "user attribute" do
    it "should be required" do
      @solution = Factory.build(:solution, :user => nil)
      @solution.valid?.should be_false
      @solution.should have(1).error_on(:user)
    end

    it "should be protected agains mass assignment" do
      @user = Factory.build(:user)
      @solution = Factory.build(:solution, :user => @user)
      @another_user = Factory.build(:user)

      @solution.attributes = { :user => @another_user }
      @solution.user.should be == @user
    end
  end

  describe "superivion attribute" do
    it "should be required" do
      @solution = Factory.build(:solution, :supervision => nil, :user => Factory.build(:user))
      @solution.valid?.should be_false
      @solution.should have(1).error_on(:supervision)
    end

    it "should be protected agains mass assignment" do
      @supervision = Factory.build(:supervision)
      @solution = Factory.build(:solution, :supervision => @supervision)
      @another_question = Factory.build(:question)

      @solution.attributes = { :supervision => @another_supervision }
      @solution.supervision.should be == @supervision
    end
  end

  describe "content attribute" do
    it "should be required" do
      @solution = Factory.build(:solution, :content => nil)
      @solution.valid?.should be_false
      @solution.should have(1).error_on(:content)
    end

    it "should be accessible to mass assignment" do
      @solution = Factory.build(:solution, :content => "Simple content")
      @solution.attributes = { :content => "Another content" }
      @solution.content.should be == "Another content"
    end
  end

  describe "rating attribute" do
    it "should allow nil" do
      @solution = Factory.build(:solution, :rating => nil)
      @solution.valid?.should be_true
    end

    it "should be numerical" do
      @solution = Factory.build(:solution, :rating => 5)
      @solution.valid?.should be_true
    end

    it "should not allow for non numerical values" do
      @solution = Factory.build(:solution, :rating => "text")
      @solution.valid?.should be_false
      @solution.should have(2).error_on(:rating)
    end

    it "should not allow for not integer values" do
      @solution = Factory.build(:solution, :rating => 1.1)
      @solution.valid?.should be_false
      @solution.should have(1).error_on(:rating)
    end

    it "should not allow values less than 1" do
      @solution = Factory.build(:solution, :rating => 0)
      @solution.valid?.should be_false
      @solution.should have(1).error_on(:rating)
    end

    it "should not allow values greater than 5" do
      @solution = Factory.build(:solution, :rating => 6)
      @solution.valid?.should be_false
      @solution.should have(1).error_on(:rating)
    end
  end

  describe "after create" do
    it "should notify supervision with #post_solution" do
      @supervision = Factory(:supervision)
      @solution = Factory.build(:solution, :supervision => @supervision)
      @supervision.should_receive(:post_solution).with(@solution)
      @solution.save!
    end
  end

  describe "after update" do
    it "should notify supervision with #post_vote_for_next_step" do
      @supervision = Factory(:supervision)
      @solution = Factory(:solution, :supervision => @supervision)
      @supervision.should_receive(:post_vote_for_next_step).with(@solution)
      @solution.update_attributes!({:rating => 5})
    end
  end
end
