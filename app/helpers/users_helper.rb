module UsersHelper
  def users_list(users, selected = nil)
    haml_tag :ul, :class => "users" do
      users.each do |user|
        is_selected = user == selected
        haml_tag :li, is_selected ? {:class => 'selected'} : {} do
          haml_concat gravatar_for user, :size => 30
          suffix = is_selected ? '*' : ''
          haml_concat link_to(user.name + suffix, user)
          if current_user.admin?
            haml_concat "|" + link_to(t(".links.delete", :default => "delete"), user, :method => :delete, :confirm => t(".confirmations.delete", :default => "You sure?"))
          end
        end
      end
    end
  end
end
