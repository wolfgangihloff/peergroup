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
    say_with_time("Updating states in existing supervisions") do
      STATES.each do |old_state,new_state|
        Supervision.update_all(["state = ?", new_state], ["state = ?", old_state])
      end
    end
  end

  def self.down
    say_with_time("Reverting updating states in existing supervisions") do
      STATES.each do |old_state,new_state|
        Supervision.update_all(["state = ?", old_state], ["state = ?", new_state])
      end
    end
  end
end
