module SupervisionPathsHelper
  def supervision_step_path(supervision)
    supervision.reload
    method = send("supervision_step_#{supervision.state}_path", supervision)
    send(method, :supervision_id => supervision.id)
  end

  def supervision_step_topic_path(supervision)
    supervision.topics.find_by_user_id(current_user.id) ? :topics_path : :new_topic_path
  end

  def supervision_step_topic_vote_path(supervision)
    supervision.voted_on_topic?(current_user) ? :topic_votes_path : :new_topic_vote_path
  end

  def supervision_step_topic_question_path(*_)
    :new_topic_question_path
  end

  def supervision_step_idea_path(*_)
    :ideas_path
  end
end

