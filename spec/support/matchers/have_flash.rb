RSpec::Matchers.define :have_flash do |expected|
  match do |actual|
    find_flash(actual) == expected
  end

  failure_message_for_should do |actual|
    "expected '#{expected}' flash, but '#{find_flash(actual)}' was set"
  end

  failure_message_for_should_not do |actual|
    "expected '#{expected}' flash to not be set"
  end

  def find_flash(actual)
    actual.within ".flash" do
      actual.text
    end
  end
end
