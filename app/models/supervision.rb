# Run:
#     rake state_machine:draw CLASS=Supervision
# to generate diagram how this state machine changes states
# It's mostly simple one step forward with possibility to step back
# to arbitrary state, that's why generated diagram is so messed with
# transitions (you can get back to particular state from all following
# states)

class Supervision < ActiveRecord::Base
  include SupervisionRedisPublisher
  def supervision_id; id; end # aliasing doesn't work

  STEPS = %w[
    waiting_for_members
    gathering_topics
    voting_on_topics
    asking_questions
    giving_answers
    providing_ideas
    voting_ideas
    giving_ideas_feedback
    providing_solutions
    voting_solutions
    giving_solutions_feedback
    giving_supervision_feedbacks
  ]

  state_machine :state, :initial => :waiting_for_members do
    before_transition all => all - [:cancelled], :do => :sufficent_users?
    before_transition [:gathering_topics, :voting_on_topics] => :asking_questions, :do => :choose_topic
    after_transition all => all, :do => [:destroy_next_step_votes, :publish_to_redis]

    before_transition :gathering_topics => :voting_on_topics, :do => :all_topics?
    before_transition :voting_on_topics => :asking_questions, :do => :all_topic_votes?
    before_transition :asking_questions => :giving_answers, :do => :all_next_step_votes?
    before_transition :giving_answers => :providing_ideas, :do => :all_answers?
    before_transition :providing_ideas => :voting_ideas, :do => :all_next_step_votes?
    before_transition :voting_ideas => :giving_ideas_feedback, :do => :all_idea_ratings?
    before_transition :giving_ideas_feedback => :providing_solutions, :do => :ideas_feedback_present?
    before_transition :providing_solutions => :voting_solutions, :do => :all_next_step_votes?
    before_transition :voting_solutions => :giving_solutions_feedback, :do => :all_solution_ratings?
    before_transition :giving_solutions_feedback => :giving_supervision_feedbacks, :do => :solutions_feedback_present?
    before_transition :giving_supervision_feedbacks => :finished, :do => :can_move_to_finished_state?

    event :join_member do
      transition :waiting_for_members => :gathering_topics, :if => :first_member_joins?
      transition all => all
    end

    event :remove_member do
      transition all - [:finished, :cancelled] => :cancelled, :if => :cancel_supervision?
      transition :gathering_topics => :asking_questions, :if => :skip_topic_voting?
      transition :gathering_topics => :voting_on_topics
      transition :voting_on_topics => :asking_questions
      transition :giving_supervision_feedbacks => :finished
      transition :asking_questions => :providing_ideas, :if => :skip_giving_answers_state?
      transition :asking_questions => :giving_answers
      transition :giving_answers => :providing_ideas
      transition :providing_ideas => :giving_ideas_feedback, :if => :skip_voting_ideas?
      transition :providing_ideas => :voting_ideas
      transition :voting_ideas => :giving_ideas_feedback
      transition :providing_solutions => :giving_solutions_feedback, :if => :skip_voting_solutions?
      transition :providing_solutions => :voting_solutions
      transition :voting_solutions => :giving_solutions_feedback
      transition all => all
    end

    event :post_topic do
      transition :gathering_topics => :asking_questions, :if => :skip_topic_voting?
      transition :gathering_topics => :voting_on_topics
    end

    event :post_topic_vote do
      transition :voting_on_topics => :asking_questions
    end

    event :post_ideas_feedback do
      transition :giving_ideas_feedback => :providing_solutions
    end

    event :post_solutions_feedback do
      transition :giving_solutions_feedback => :giving_supervision_feedbacks
    end

    event :post_supervision_feedback do
      transition :giving_supervision_feedbacks => :finished
    end

    event :post_vote_for_next_step do
      transition :asking_questions => :providing_ideas, :if => :skip_topic_voting?
      transition :asking_questions => :giving_answers
      transition :giving_answers => :providing_ideas
      transition :providing_ideas => :giving_ideas_feedback?, :if => :skip_voting_ideas?
      transition :providing_ideas => :voting_ideas
      transition :voting_ideas => :giving_ideas_feedback
      transition :providing_solutions => :giving_solutions_feedback, :if => :skip_voting_solutions?
      transition :providing_solutions => :voting_solutions
      transition :voting_solutions => :giving_solutions_feedback
    end

    event :step_back_to_asking_questions do
      transition [
        :asking_questions,
        :giving_answers,
        :providing_ideas,
        :voting_ideas,
        :giving_ideas_feedback,
        :providing_solutions,
        :voting_solutions,
        :giving_solutions_feedback,
        :giving_supervision_feedbacks
      ] => :asking_questions
    end

    event :step_back_to_providing_ideas do
      transition [
        :voting_ideas,
        :giving_ideas_feedback,
        :providing_solutions,
        :voting_solutions,
        :giving_solutions_feedback,
        :giving_supervision_feedbacks
      ] => :providing_ideas
    end

    event :step_back_to_giving_ideas_feedback do
      transition [
        :providing_solutions,
        :voting_solutions,
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

  has_many :topics, :dependent => :destroy, :order => "created_at ASC"
  has_many :topic_votes, :through => :topics, :source => :votes
  has_many :next_step_votes, :class_name => "Vote", :as => :statement, :dependent => :destroy
  has_many :topic_questions, :class_name => "Question", :dependent => :destroy, :order => "created_at ASC"
  has_many :questions, :dependent => :destroy, :order => "created_at ASC"
  has_many :ideas, :dependent => :destroy, :order => "created_at ASC"
  has_many :solutions, :dependent => :destroy, :order => "created_at ASC"
  has_many :supervision_feedbacks, :dependent => :destroy, :order => "created_at ASC"
  has_many :memberships, :class_name => "SupervisionMembership"
  has_many :members, :through => :memberships, :source => :user, :class_name => "User"
  # these 2 has DESC to show only latest feedback, it's has_one relation
  has_one :ideas_feedback, :dependent => :destroy, :order => "created_at DESC"
  has_one :solutions_feedback, :dependent => :destroy, :order => "created_at DESC"
  has_one :chat_room, :dependent => :destroy
  belongs_to :topic
  belongs_to :group

  validates :group, :presence => true

  delegate :user, :content, :user_id, :to => :topic, :prefix => true, :allow_nil => true
  delegate :name, :to => :group, :prefix => true
  delegate :id, :to => :chat_room, :prefix => true

  attr_accessible :state_event

  after_create :create_chat_room, :publish_notification_to_redis

  def self.finished
    with_state(:finished)
  end

  def self.cancelled
    with_state(:cancelled)
  end

  def self.in_progress
    without_state(:finished, :cancelled)
  end

  def in_progress?
    !finished? and !cancelled?
  end

  def first_member_joins?
    members.count == 2
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

  def problem_owner
    topic_user if topic
  end

  def problem_owner?(user)
    problem_owner == user
  end

  def step_finished?(desired_step)
    final_step = STEPS.index(desired_step.to_s)
    previous_steps = STEPS.to(final_step)
    previous_steps.exclude?(state)
  end

  def publish_notification_to_redis
    json_string = {:message => { 
      :content => "New supervision started",
      :id => self.id,
      :created_at => self.created_at
    } }.to_json
    REDIS.publish("group:#{self.group.id}", json_string )
  end

  protected

  def sufficent_users?
    members.count > 1
  end

  def cancel_supervision?
    if topic
      !members.exists?(topic_user)
    else
      members.empty?
    end
  end

  def ideas_feedback_present?
    ideas_feedback.present?
  end

  def solutions_feedback_present?
    solutions_feedback.present?
  end

  def all_topics?
    members.all? { |m| topics.exists?(:user_id => m.id) }
  end

  def all_topic_votes?
    members.all? { |m| topic_votes.exists?(:user_id => m.id) }
  end

  def skip_topic_voting?
    all_topics? && topics.votable.count == 1
  end

  def all_next_step_votes?
    members.all? { |m| problem_owner?(m) || next_step_votes.exists?(:user_id => m.id) }
  end

  def can_move_to_finished_state?
    all_supervision_feedbacks?
  end

  def all_answers?
    questions.unanswered.empty?
  end

  def skip_giving_answers_state?
    all_next_step_votes? && all_answers?
  end

  def all_idea_ratings?
    ideas.not_rated.empty?
  end

  def skip_voting_ideas?
    all_next_step_votes? && all_idea_ratings?
  end

  def all_solution_ratings?
    solutions.not_rated.empty?
  end

  def skip_voting_solutions?
    all_next_step_votes? && all_solution_ratings?
  end

  def all_supervision_feedbacks?
    members.all? { |m| supervision_feedbacks.exists?(:user_id => m.id) }
  end

  def destroy_next_step_votes
    next_step_votes.destroy_all
  end

  def choose_topic
    self.topic = topics.votable.sort { |a,b| a.votes.count <=> b.votes.count}.last
  end

  def supervision_publish_attributes
    {:only => [:id, :state, :topic_id], :methods => :topic_user_id}
  end
end
