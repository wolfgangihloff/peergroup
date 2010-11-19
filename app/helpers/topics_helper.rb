module TopicsHelper
  def topic_content(topic)
    if topic.content.blank?
      t(".topic.skip_notice", :default => "%{username} did not submitted his topic.", :username => topic.user.name)
    else
      topic.content
    end
  end
end
