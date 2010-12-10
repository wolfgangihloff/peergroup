module SupervisionPathsHelper
  def supervision_step_path(supervision)
    return supervision_path(supervision)

    supervision.reload
    method_or_path = send("supervision_#{supervision.state}_step_path", supervision)

    case method_or_path
    when Symbol then send(method_or_path, :supervision_id => supervision.id)
    else method_or_path
    end
  end

  def supervision_topic_step_path(supervision)
    supervision.topics.find_by_user_id(current_user.id) ? :supervision_topics_path : :new_supervision_topic_path
  end

  def supervision_topic_vote_step_path(supervision)
    supervision.voted_on_topic?(current_user) ? :supervision_topic_votes_path : :new_supervision_topic_vote_path
  end

  def supervision_topic_question_step_path(*_)
    :new_supervision_topic_question_path
  end

  %w{idea idea_feedback}.each do |step|
    define_method "supervision_#{step}_step_path" do |_|
      :supervision_ideas_path
    end
  end

  %w{solution solution_feedback}.each do |step|
    define_method "supervision_#{step}_step_path" do |_|
      :supervision_solutions_path
    end
  end

  def supervision_supervision_feedback_step_path(supervision)
    :supervision_supervision_feedbacks_path
  end

  def supervision_finished_step_path(supervision)
    supervision_path(supervision)
  end
end

