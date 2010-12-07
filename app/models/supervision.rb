class Supervision < ActiveRecord::Base

  # Run:
  #     rake state_machine:draw CLASS=Supervision
  # to generate diagram how this state machine changes states
  state_machine :state, :initial => :topic do
    before_transition :topic => :topic_vote, :do => :choose_topic
    after_transition all => all, :do => :destroy_next_step_votes

    event :post_topic do
      transition :topic => :topic_vote, :if => :all_topics?
    end
    event :post_topic_vote do
      transition :topic_vote => :topic_question, :if => :all_topic_votes?
    end
    event :owner_idea_feedback do
      transition :idea_feedback => :solution
    end
    event :owner_solution_feedback do
      transition :solution_feedback => :supervision_feedback
    end
    event :general_feedback do
      transition :supervision_feedback => :finished, :if => :can_move_to_finished_state?
    end
    event :post_vote_for_next_step do
      transition :topic_question => :idea, :if => :can_move_to_idea_state?
      transition :idea => :idea_feedback, :if => :can_move_to_idea_feedback_state?
      transition :solution => :solution_feedback, :if => :can_move_to_solution_feedback_state?
    end
  end

  has_many :topics
  has_many :topic_votes, :through => :topics, :source => :votes
  has_many :next_step_votes, :class_name => "Vote", :as => :statement
  has_many :topic_questions, :class_name => "Question"
  has_many :questions
  has_many :ideas
  has_many :solutions

  has_one :ideas_feedback
  has_one :solutions_feedback
  has_many :supervision_feedbacks

  belongs_to :topic
  belongs_to :group

  scope :finished, :conditions => {:state => "finished"}
  scope :unfinished, :conditions => ["state <> ?", "finished"]

  def all_topics?
    group.members.all? {|m| topics.where(:user_id => m.id).any? }
  end

  def all_topic_votes?
    group.members.all? {|m| topic_votes.where(:user_id => m.id).present? }
  end

  def all_next_step_votes?
    group.members.all? {|m| problem_owner?(m) || !next_step_votes.where(:user_id => m.id).empty? }
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
    group.members.all? {|m| supervision_feedbacks.count(:conditions => {:user_id => m.id}) > 0 }
  end

  def destroy_next_step_votes
    next_step_votes.destroy_all
  end

  def voted_on_topic?(user)
    !topic_votes(true).where(:user_id => user.id).empty?
  end

  def voted_on_next_step?(user)
    !next_step_votes(true).where(:user_id => user.id).empty?
  end

  def posted_supervision_feedback?(user)
    supervision_feedbacks.count(:conditions => {:user_id => user.id}) > 0
  end

  def choose_topic
    self.topic = topics.sort {|a,b| a.votes.count <=> b.votes.count}.last
  end

  def problem_owner
    topic && topic.user
  end

  def problem_owner?(user)
    problem_owner == user
  end
end

