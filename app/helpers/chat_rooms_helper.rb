module ChatRoomsHelper
  #def select_leader_link(chat_room, chat_user)
    #user = chat_user.user
    #return t(".captions.leader", :default => "Leader") if user == chat_room.leader

    #path = select_leader_chat_room_path(@chat_room, :user_id => user.id)
    #link_to t(".links.leader", :default => "Leader"), "#" + path
  #end

  #def select_problem_owner_link(chat_room, chat_user)
    #user = chat_user.user
    #return t(".captions.problem_owner", :default => "Problem owner") if user == @chat_room.problem_owner

    #if current_user == @chat_room.leader
      #path = select_problem_owner_chat_room_path(@chat_room, :user_id => user.id)
      #link_to t(".links.problem_owner", :default => "Problem owner"), "#" + path
    #end
  #end

  #def chat_user_class(chat_room, chat_user)
    #role_class = case chat_user.user
                 #when chat_room.leader then "leader"
                 #when chat_room.problem_owner then "problem_owner"
                 #else ""
                 #end

    #chat_user.active? ? role_class + ' active' : role_class
  #end
end

