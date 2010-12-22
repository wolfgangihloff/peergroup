source :gemcutter

gem "rails", "=3.0.3"
gem "sqlite3-ruby", :require => "sqlite3"
gem "will_paginate", "~> 3.0.pre2"
gem "mongo_mapper"
gem "bson_ext"
gem "haml"
gem "bundler", ">=1.0.0"
gem "formtastic"
gem "friendly_id", "~> 3.1"
gem "rdiscount"
gem "faker"
gem "compass"
gem "state_machine"
gem "rack-sprockets", :require => "rack/sprockets"
gem "redis"
gem "SystemTimer" # for redis

group :staging do
#  gem "pg"
  gem "thin"
end

group :test, :development, :cucumber do
  gem "factory_girl_rails"
  gem "database_cleaner"
end

group :test do
  gem "webrat"
  gem "test-unit"
  gem "rspec", ">=2.0.0.rc"
  gem "rspec-rails", ">=2.0.0.rc"
end

group :development do
  gem "nifty-generators"
  gem "ruby-graphviz"
end

group :cucumber do
  gem "cucumber-rails"
  gem "pickle"
  gem "capybara", "=0.3.9"
  gem "launchy"
  gem "selenium-webdriver"
end

