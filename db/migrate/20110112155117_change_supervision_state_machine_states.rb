class ChangeSupervisionStateMachineStates < ActiveRecord::Migration
  STATES = {
    "topic"                => "gathering_topics",
    "topic_vote"           => "voting_on_topics",
    "topic_question"       => "asking_questions",
    "idea"                 => "providing_ideas",
    "idea_feedback"        => "giving_ideas_feedback",
    "solution"             => "providing_solutions",
    "solution_feedback"    => "giving_solutions_feedback",
    "supervision_feedback" => "giving_supervision_feedbacks",
    "finished"             => "finished"
  }
  def self.up
    STATES.each do |old_state,new_state|
      Supervision.update_all(["state = ?", new_state], ["state = ?", old_state])
    end
  end

  def self.down
    STATES.each do |old_state,new_state|
      Supervision.update_all(["state = ?", old_state], ["state = ?", new_state])
    end
  end
end
