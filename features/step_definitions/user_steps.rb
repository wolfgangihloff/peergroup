Given /^the user "([^"]*)" is signed in/ do |name|
  user = User.find_by_name(name) or raise "No user with '#{name}' name."

  Given %Q{I am on the homepage}
  And %Q{I follow "Sign in"}
  Then %Q{I should be on the signin page}
  When %Q{I fill in "Email" with "#{user.email}"}
  And %Q{I fill in "Password" with "foobar"}
  And %Q{I press "Sign in"}
  Then %Q{show me the page}
  Then %Q{I should see "#{user.name}'s Group List"}
end
