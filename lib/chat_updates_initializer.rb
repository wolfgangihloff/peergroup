module ChatUpdatesInitializer
  protected

  def initialized_chat_update(options = {})
    ChatUpdate.new(options).tap do |chat_update|
      chat_update.user = current_user
      chat_update.chat_room = @chat_room
      chat_update.save!
    end
  end
end
