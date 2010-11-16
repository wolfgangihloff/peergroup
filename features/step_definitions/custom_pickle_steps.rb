Then /^(.+) within #{capture_model}$/ do |action, container|
  record = model!(container)
  selector = "##{dom_id(record)}"
  Then "#{action} within \"#{selector}\""
end

Given /^#{capture_model} is #{capture_model}(?:'s)? (\w+)$/ do |target, owner, association|
  owner = model!(owner)
  owner.send("#{association}=", model!(target))
  owner.save!
end

