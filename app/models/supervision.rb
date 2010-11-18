class Supervision < ActiveRecord::Base

  STEPS = %w{topic topic_vote topic_question idea idea_feedback solution finished}

  validates_inclusion_of :state, :in => STEPS

  has_many :topics
  has_many :topic_votes, :through => :topics, :source => :votes
  has_many :next_step_votes, :class_name => "Vote", :as => :statement
  has_many :topic_questions, :class_name => "Question"
  has_many :questions
  has_many :ideas

  has_one :ideas_feedback

  belongs_to :topic
  belongs_to :group

  scope :unfinished, :conditions => ["state <> ?", "finished"]

  before_validation(:on => :create) { self.state ||= "topic" }

  %w{topics topic_votes}.each do |step|
    define_method(:"all_#{step}?") do
      group.members.all? {|m| !send(step).where(:user_id => m.id).empty? }
    end
  end

  def all_next_step_votes?
    group.members.all? {|m| problem_owner?(m) || !next_step_votes.where(:user_id => m.id).empty? }
  end

  def can_move_to_idea_state?
    state == "topic_question" && all_next_step_votes? && all_answers?
  end

  def can_move_to_idea_feedback_state?
    state == "idea" && all_next_step_votes? && all_idea_ratings?
  end

  def all_answers?
    questions.unanswered.empty?
  end

  def all_idea_ratings?
    ideas.not_rated.empty?
  end

  def next_step!
    self.state = STEPS[STEPS.index(state) + 1]
    save!
    next_step_votes.destroy_all
  end

  def voted_on_topic?(user)
    !topic_votes(true).where(:user_id => user.id).empty?
  end

  def voted_on_next_step?(user)
    !next_step_votes(true).where(:user_id => user.id).empty?
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

