# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'database_cleaner'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

# TODO: Move all webrat specs to capybara
Webrat.configure do |config|
  config.mode = :rails
end

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  config.include Webrat::HaveTagMatcher, :type => :controller

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  #config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  config.before(:all) do
    Factory.find_definitions
    DatabaseCleaner.clean_with :truncation
  end

  # We mock REDIS to not depend on it to run our tests.
  RSpec::Mocks::setup(self)
  REDIS = double(Object.new)

  # We have to stub publish, as it's run with callbacks for some models,
  # and we don't want to specify this stub in every test which checks
  # this callbacks
  config.before do
    REDIS.stub(:publish)
  end

  def sign_in(user = Factory(:user))
    controller.current_user = user
  end
end

