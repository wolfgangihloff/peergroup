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

  %w{idea idea_feedback}.each do |step|
    define_method "supervision_#{step}_step_path" do |_|
      :ideas_path
    end
  end

  %w{solution solution_feedback finished}.each do |step|
    define_method "supervision_#{step}_step_path" do |_|
      :solutions_path
    end
  end
end

