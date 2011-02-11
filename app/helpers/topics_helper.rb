module TopicsHelper
  def topic_content(topic)
    if topic.content?
      topic.content
    else
      t(".topic.skip_notice", :default => "%{username} did not submitted his topic.", :username => topic.user.name)
    end
  end
end
