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

When /^#{capture_model} ([\w]+) is #{capture_value}$/ do |name, attribute, value|
  value = /^[+-]?[0-9_]+(\.\d+)?$/.match(value) ? value : eval(value)

  record = model(name)
  record.send(:"#{attribute}=", value)
  record.save!
end

