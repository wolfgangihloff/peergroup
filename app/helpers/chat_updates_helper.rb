module ChatUpdatesHelper
  def update_feeds(chat_updates)
    chat_updates.map do |chat_update|
      { :id => dom_id(chat_update),
        :update => render("chat_update", :chat_update => chat_update)
      }
    end.to_json
  end

  def chat_update_class(chat_update)
    klass = chat_update.state
    chat_update.parent.nil? ? klass + ' root' : klass
  end
end

