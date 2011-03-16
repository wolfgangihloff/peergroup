source :gemcutter

gem "rails", "=3.0.4"
gem "sqlite3-ruby", :require => "sqlite3"
gem "will_paginate", "~> 3.0.pre2"
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
gem "redis", :git => "git://github.com/ezmobius/redis-rb.git" # git repo for unix socket support
gem "hiredis" # for better Redis support
gem "SystemTimer" # for redis
gem "concerned_with"

group :staging do
#  gem "pg"
  gem "thin"
end

group :test, :development do
  gem "factory_girl_rails"
  gem "database_cleaner"
  gem "rspec-rails"
  gem "capybara", :git => "git://github.com/jnicklas/capybara.git"
end

group :test do
  gem "webrat"
  gem "test-unit"
  gem "rspec"
  gem "selenium-webdriver"
end

group :development do
  gem "nifty-generators", :require => false
  gem "ruby-graphviz"
  gem "metric_fu"
end

#group :cucumber do
  #gem "cucumber-rails"
  #gem "pickle"
  #gem "capybara", "=0.3.9"
  #gem "launchy"
  #gem "selenium-webdriver"
#end

