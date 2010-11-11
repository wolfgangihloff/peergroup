Then /^(.+) within #{capture_model}$/ do |action, container|
  record = model!(container)
  selector = "##{dom_id(record)}"
  Then "#{action} within \"#{selector}\""
end

