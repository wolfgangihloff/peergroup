require 'rubygems'
require 'spork'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  # require 'simplecov'
  # SimpleCov.start 'rails'
  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'database_cleaner'

  require 'capybara/rspec'
  require 'capybara/rails'


  Capybara.default_wait_time = 10
  Capybara.server_port = 3666
  Capybara.javascript_driver = :webkit

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
    config.include Devise::TestHelpers, :type => :controller
    # config.filter_run_excluding :slow => true  
    # config.run_all_when_everything_filtered = true
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
  end
end

Spork.each_run do
  # This code will be run each time you run your specs.
  FactoryGirl.reload
end


# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.

# Helper methods:
# ===============

def sign_in_interactive(user = FactoryGirl.create(:user))
  visit "/"
  click_link "Sign in"
  fill_in "Email", :with => user.email
  fill_in "Password", :with => user.password
  click_button "Sign in"
end
