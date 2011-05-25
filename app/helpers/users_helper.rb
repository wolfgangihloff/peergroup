module UsersHelper
  def marked_user_name(user, selected_user)
    user == selected_user ? "#{user.name} *" : user.name
  end
end
