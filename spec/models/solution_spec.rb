require "spec_helper"

describe Solution do
  [:user, :supervision, :content].each do |attribute|
    it { should validate_presence_of(attribute) }
  end
  [:user_id, :supervision_id].each do |attribute|
    it { should_not allow_mass_assignment_of(attribute) }
  end

  it { should validate_numericality_of(:rating)}
  it { should allow_value(nil).for(:rating) }
  it { should_not allow_value("text").for(:rating) }
  it { should_not allow_value(1.1).for(:rating) }
  it { should_not allow_value(0).for(:rating) }
  it { should_not allow_value(6).for(:rating) }

  describe "after create" do
    it "should publish solution to Redis channel" do
      @solution = Factory.build(:solution)
      @solution.should_receive(:publish_to_redis)
      @solution.save!
    end
  end

  describe "after update" do
    it "should notify supervision with #post_vote_for_next_step" do
      @supervision = Factory(:supervision)
      @solution = Factory(:solution, :supervision => @supervision)
      @supervision.should_receive(:post_vote_for_next_step)
      @solution.update_attributes!(:rating => 5)
    end

    it "should publish rated solution to Redis channel" do
      @solution = Factory(:solution)
      @solution.should_receive(:publish_to_redis)
      @solution.update_attributes!(:rating => 5)
    end
  end

  it "should include SupervisionRedisPublisher module" do
    Solution.new.should respond_to(:publish_to_redis)
  end

  describe "#supervision_publish_attributed" do
    it "should have only known options" do
      @answer = Solution.new
      @answer.supervision_publish_attributes.should == {:only => [:id, :content, :rating, :user_id]}
    end
  end
end
