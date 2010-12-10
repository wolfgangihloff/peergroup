module SupervisionsHelper
  def step_finished?(supervision, step)
    final_state = Supervision::STATES.index(step.to_s)
    previous_steps = Supervision::STATES.to(final_state)
    previous_steps.exclude? supervision.state
  end
end
