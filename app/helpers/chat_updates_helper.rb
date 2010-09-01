module ChatUpdatesHelper
  def update_feeds(chat_updates)
    chat_updates.map do |chat_update|
      {:id => dom_id(chat_update),
       :update => render("chat_update", :object => chat_update)
      }
    end.to_json
  end
end

