module ChatRoomsHelper
  def select_leader_link(chat_room, user)
    if user == chat_room.leader
      "Leader"
    else
      path = select_leader_chat_room_path(@chat_room, :user_id => user.id)
      link_to "Leader", path, :method => :post
    end
  end

  def select_problem_owner_link(chat_room, user)
    if user == @chat_room.problem_owner || current_user != @chat_room.leader
      "Problem owner"
    else
      path = select_problem_owner_chat_room_path(@chat_room, :user_id => user.id)
      link_to "Problem owner", path, :method => :post
    end
  end
end
