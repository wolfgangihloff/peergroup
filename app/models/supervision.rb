require "supervision_redis_publisher"

# Run:
#     rake state_machine:draw CLASS=Supervision
# to generate diagram how this state machine changes states
# It's mostly simple one step forward with possibility to step back
# to arbitrary state, that's why generated diagram is so messed with
# transitions (you can get back to particular state from all following
# states)

class Supervision < ActiveRecord::Base
  include SupervisionRedisPublisher
  def supervision_id; id; end # aliasing doesn't work, don't know why yet

  STATES = [
    "gathering_topics",
    "voting_on_topics",
    "asking_questions",
    "providing_ideas",
    "giving_ideas_feedback",
    "providing_solutions",
    "giving_solutions_feedback",
    "giving_supervision_feedbacks",
    "finished"
  ]

  state_machine :state, :initial => :gathering_topics do
    before_transition :voting_on_topics => :asking_questions, :do => :choose_topic
    after_transition all => all, :do => [ :destroy_next_step_votes, :publish_to_redis ]

    event :post_topic do
      transition :gathering_topics => :voting_on_topics, :if => :all_topics?
    end
    event :post_topic_vote do
      transition :voting_on_topics => :asking_questions, :if => :all_topic_votes?
    end
    event :post_ideas_feedback do
      transition :giving_ideas_feedback => :providing_solutions
    end
    event :post_solutions_feedback do
      transition :giving_solutions_feedback => :giving_supervision_feedbacks
    end
    event :post_supervision_feedback do
      transition :giving_supervision_feedbacks => :finished, :if => :can_move_to_finished_state?
    end
    event :post_vote_for_next_step do
      transition :asking_questions => :providing_ideas, :if => :can_move_to_idea_state?
      transition :providing_ideas => :giving_ideas_feedback, :if => :can_move_to_idea_feedback_state?
      transition :providing_solutions => :giving_solutions_feedback, :if => :can_move_to_solution_feedback_state?
    end

    event :step_back_to_asking_questions do
      transition [
        :providing_ideas,
        :giving_ideas_feedback,
        :providing_solutions,
        :giving_solutions_feedback,
        :giving_supervision_feedbacks
      ] => :asking_questions
    end

    event :step_back_to_providing_ideas do
      transition [
        :giving_ideas_feedback,
        :providing_solutions,
        :giving_solutions_feedback,
        :giving_supervision_feedbacks
      ] => :providing_ideas
    end

    event :step_back_to_giving_ideas_feedback do
      transition [
        :providing_solutions,
        :giving_solutions_feedback,
        :giving_supervision_feedbacks
      ] => :giving_ideas_feedback
    end

    event :step_back_to_providing_solutions do
      transition [
        :giving_solutions_feedback,
        :giving_supervision_feedbacks
      ] => :providing_solutions
    end

    event :step_back_to_giving_solutions_feedback do
      transition [
        :giving_supervision_feedbacks
      ] => :giving_solutions_feedback
    end
  end

  has_many :topics, :dependent => :destroy
  has_many :topic_votes, :through => :topics, :source => :votes
  has_many :next_step_votes, :class_name => "Vote", :as => :statement, :dependent => :destroy
  has_many :topic_questions, :class_name => "Question", :dependent => :destroy
  has_many :questions, :dependent => :destroy
  has_many :ideas, :dependent => :destroy
  has_many :solutions, :dependent => :destroy

  has_one :ideas_feedback, :dependent => :destroy
  has_one :solutions_feedback, :dependent => :destroy
  has_many :supervision_feedbacks, :dependent => :destroy

  belongs_to :topic
  belongs_to :group

  validates :group, :presence => true

  def self.finished
    with_state(:finished)
  end

  def self.unfinished
    without_state(:finished)
  end

  attr_accessible

  def all_topics?
    group.members.all? {|m| topics.exists?(:user_id => m.id) }
  end

  def all_topic_votes?
    group.members.all? {|m| topic_votes.exists?(:user_id => m.id) }
  end

  def all_next_step_votes?
    group.members.all? {|m| problem_owner?(m) || next_step_votes.exists?(:user_id => m.id) }
  end

  def can_move_to_idea_state?
    all_next_step_votes? && all_answers?
  end

  def can_move_to_idea_feedback_state?
    all_next_step_votes? && all_idea_ratings?
  end

  def can_move_to_solution_feedback_state?
    all_next_step_votes? && all_solution_ratings?
  end

  def can_move_to_finished_state?
    all_supervision_feedbacks?
  end

  def all_answers?
    questions.unanswered.empty?
  end

  def all_idea_ratings?
    ideas.not_rated.empty?
  end

  def all_solution_ratings?
    solutions.not_rated.empty?
  end

  def all_supervision_feedbacks?
    group.members.all? {|m| supervision_feedbacks.exists?(:user_id => m.id) }
  end

  def destroy_next_step_votes
    next_step_votes.destroy_all
  end

  def posted_topic?(user)
    topics.exists?(:user_id => user.id)
  end

  def voted_on_topic?(user)
    topic_votes.exists?(:user_id => user.id)
  end

  def voted_on_next_step?(user)
    next_step_votes.exists?(:user_id => user.id)
  end

  def posted_supervision_feedback?(user)
    supervision_feedbacks.exists?(:user_id => user.id)
  end

  def choose_topic
    self.topic = topics.sort {|a,b| a.votes.count <=> b.votes.count}.last
  end

  def problem_owner
    topic.user if topic
  end

  def problem_owner?(user)
    problem_owner == user
  end

  def step_finished?(step)
    final_state = STATES.index(step.to_s)
    previous_steps = STATES.to(final_state)
    previous_steps.exclude? state
  end

  def supervision_publish_attributes
    {:only => [:id, :state, :topic_id]}
  end

end

