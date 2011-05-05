source :gemcutter

gem "rails", "~> 3.0.5"
gem "sqlite3"
gem "will_paginate", "~> 3.0.pre2"
gem "bson_ext"
gem "haml"
gem "sass"
gem "compass"
gem "formtastic"
gem "friendly_id", "~> 3.1"
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
  gem "rspec-rails", ">= 2.6.0.rc4"
  gem "ruby-debug"
end

group :test do
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
