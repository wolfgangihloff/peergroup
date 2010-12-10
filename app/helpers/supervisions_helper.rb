module SupervisionsHelper
  def step_finished?(supervision, step)
    previous_steps = Supervision::STATES.take_while { |s| step.to_s != s }
    previous_steps.exclude? supervision.state
  end
end
