When /^I wait (\d+) second$/ do |seconds_count|
  sleep seconds_count.to_i + 0.1
end

