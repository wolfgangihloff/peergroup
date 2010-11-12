module SupervisionPathsHelper
  def supervision_step_path(supervision)
    supervision.reload
    send("supervision_step_#{supervision.state}_path", supervision)
  end

  def supervision_step_topic_path(supervision)
    if supervision.topics.find_by_user_id(current_user.id)
      topics_path(:supervision_id => supervision.id)
    else
      new_topic_path(:supervision_id => supervision.id)
    end
  end

  def supervision_step_topic_vote_path(supervision)
    if supervision.voted_on_topic?(current_user)
      topic_votes_path(:supervision_id => supervision.id)
    else
      new_topic_vote_path(:supervision_id => supervision.id)
    end
  end

  def supervision_step_topic_question_path(supervision)
    new_topic_question_path(:supervision_id => supervision.id)
  end
end

