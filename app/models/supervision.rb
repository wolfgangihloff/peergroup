class Supervision < ActiveRecord::Base

  STATES = %w/ topic topic_vote topic_question idea idea_feedback solution solution_feedback supervision_feedback finished /

  # Run:
  #     rake state_machine:draw CLASS=Supervision
  # to generate diagram how this state machine changes states
  state_machine :state, :initial => :topic do
    after_transition :topic_vote => :topic_question, :do => :choose_topic
    after_transition all => all, :do => [ :destroy_next_step_votes, :publish_transition_change ]

    event :post_topic do
      transition :topic => :topic_vote, :if => :all_topics?
    end
    event :post_topic_vote do
      transition :topic_vote => :topic_question, :if => :all_topic_votes?
    end
    event :post_ideas_feedback do
      transition :idea_feedback => :solution
    end
    event :post_solutions_feedback do
      transition :solution_feedback => :supervision_feedback
    end
    event :post_supervision_feedback do
      transition :supervision_feedback => :finished, :if => :can_move_to_finished_state?
    end
    event :post_vote_for_next_step do
      transition :topic_question => :idea, :if => :can_move_to_idea_state?
      transition :idea => :idea_feedback, :if => :can_move_to_idea_feedback_state?
      transition :solution => :solution_feedback, :if => :can_move_to_solution_feedback_state?
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

  scope :finished, :conditions => {:state => "finished"}
  scope :unfinished, :conditions => ["state <> ?", "finished"]

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

  def publish_transition_change(transition)
    # REDIS.publish(...)
  end

  # Wrappers for state machine events, lets us publish informations to
  # Redis when users post topics/questions/answers/votes
  def post_topic(topic, *args)
    # REDIS.publish(...)
    super
  end

  def post_topic_vote(vote, *args)
    # REDIS.publish(...)
    super
  end

  def post_vote_for_next_step(vote, *args)
    # REDIS.publis(...)
    super
  end

  def post_ideas_feedback(feedback, *args)
    super
  end

  def post_solutions_feedback(feedback, *args)
    # REDIS.publish(...)
    super
  end

  def post_supervision_feedback(feedback, *args)
    super
  end

  def post_question(question)
  end

  def post_idea(idea)
  end

  def post_solution(solution)
  end
end

