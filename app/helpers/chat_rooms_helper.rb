module ChatRoomsHelper
  def select_leader_link(chat_room, user)
    return "Leader" if user == chat_room.leader

    path = select_leader_chat_room_path(@chat_room, :user_id => user.id)
    link_to "Leader", path, :method => :post
  end

  def select_problem_owner_link(chat_room, user)
    return "Problem owner" if user == @chat_room.problem_owner

    if current_user == @chat_room.leader
      path = select_problem_owner_chat_room_path(@chat_room, :user_id => user.id)
      link_to "Problem owner", path, :method => :post
    end
  end
end
