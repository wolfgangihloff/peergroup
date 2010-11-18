module SupervisionPathsHelper
  def supervision_step_path(supervision)
    supervision.reload
    method = send("supervision_#{supervision.state}_step_path", supervision)
    send(method, :supervision_id => supervision.id)
  end

  def supervision_topic_step_path(supervision)
    supervision.topics.find_by_user_id(current_user.id) ? :topics_path : :new_topic_path
  end

  def supervision_topic_vote_step_path(supervision)
    supervision.voted_on_topic?(current_user) ? :topic_votes_path : :new_topic_vote_path
  end

  def supervision_topic_question_step_path(*_)
    :new_topic_question_path
  end

  def supervision_idea_step_path(*_)
    :ideas_path
  end

  def supervision_idea_feedback_step_path(*_)
    :ideas_path
  end

  def supervision_solution_step_path(*_)
    :solutions_path
  end
end

