# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'database_cleaner'

require 'capybara/rspec'
require 'capybara/rails'

Capybara.default_wait_time = 5
Capybara.server_port = NODE_CONFIG[:port]

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

DatabaseCleaner.strategy = :truncation

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # config.include Webrat::HaveTagMatcher, :type => :controller

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.include HttpBasicSpecHelper, :type => :controller

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # Stop after first failing test
  # config.fail_fast = true

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
    REDIS.flushdb
  end

  # Helper methods:
  # ===============

  # Sign in user for test purposes
  def sign_in(user = FactoryGirl.create(:user))
    controller.current_user = user
  end

  def sign_in_interactive(user = FactoryGirl.create(:user))
    visit "/"
    click_link "Sign in"
    fill_in "Email", :with => user.email
    fill_in "Password", :with => user.password
    click_button "Sign in"
  end
end
