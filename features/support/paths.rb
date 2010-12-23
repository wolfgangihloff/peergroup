module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page/
      '/'

    when /the (.+) for "([^"]*)" page/i
      path_components = $1.split(/\s+/)
      if path_components.first == "new"
        path_components = ["new", "supervision"] + path_components[1..-1]
      else
        path_components = ["supervision"] + path_components
      end
      supervision = find_model!("supervision: \"#{$2}\"")
      self.send(path_components.push('path').join('_').to_sym, supervision)

    # the following are examples using path_to_pickle

    when /^#{capture_model}(?:'s)? page$/                           # eg. the forum's page
      path_to_pickle $1

    when /^#{capture_model}(?:'s)? #{capture_model}(?:'s)? page$/   # eg. the forum's post's page
      path_to_pickle $1, $2

    when /^#{capture_model}(?:'s)? #{capture_model}'s (.+?) page$/  # eg. the forum's post's comments page
      path_to_pickle $1, $2, :extra => $3                           #  or the forum's post's edit page

    when /^#{capture_model}(?:'s)? (.+?) page$/                     # eg. the forum's posts page
      path_to_pickle $1, :extra => $2                               #  or the forum's edit page

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    when /^(.*)'s profile page$/i
      user_path(User.find_by_name($1))

    when /^the all groups page$/i
      groups_path(:all => true)

    when /the "([^"]*)" group chat/i
      group_chat_room_path(Group.find_by_name($1))

    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
