source :gemcutter

gem "rake", "~> 0.8.7"
gem "rails", "~> 3.0.8.rc1"
gem "sqlite3"
gem "will_paginate", "~> 3.0.pre2"
gem "bson_ext"
gem "haml"
gem "sass"
gem "compass"
gem "formtastic"
gem "friendly_id"
gem "rdiscount"
gem "faker"
gem "state_machine"
gem "rack-sprockets", :require => "rack/sprockets"
gem "redis"
gem "hiredis" # for better Redis support
gem "SystemTimer" # for redis
gem "routing-filter"

group :staging do
  # gem "pg"
  gem "thin"
end

group :test, :development do
  gem "rspec-rails"
  gem "ruby-debug"
end

group :test do
  gem "shoulda-matchers"
  gem "selenium-webdriver"
  gem "factory_girl_rails"
  gem "database_cleaner"
  gem "capybara", "~> 1.0.0.beta1"
end

group :development do
  gem "nifty-generators", :require => false
  gem "ruby-graphviz"
  gem "metric_fu"
  gem "tolk", :git => "git://github.com/cover/tolk.git"
end
