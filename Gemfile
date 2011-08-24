source :rubygems

gem "rails", "3.1.0.rc6"
gem "will_paginate", "~> 3.0.pre2"
gem "haml"
gem "formtastic", "~> 2.0.0.rc1"
gem "friendly_id"
gem "rdiscount"
gem "state_machine"
# gem "rack-sprockets", :require => "rack/sprockets"
gem "redis"
gem "hiredis" # for better Redis support
gem "routing-filter"
# for redis
gem "SystemTimer", :require => nil, :platform => :ruby_18

group :assets do
  gem "sass-rails", "~> 3.1.0.rc6"
  gem "uglifier"
  gem "sprockets"
  gem "compass", :git => "git://github.com/chriseppstein/compass.git", :branch => "rails31"
end

group :production do
  gem "pg"
end

group :test, :development do
  gem "rspec-rails"
  gem "ruby-debug", :platform => :ruby_18
  gem "ruby-debug19", :require => "ruby-debug", :platform => :ruby_19
  gem "sqlite3"
end

group :test do
  gem "shoulda-matchers", :git => "git://github.com/thoughtbot/shoulda-matchers.git"
  gem "selenium-webdriver"
  gem "factory_girl_rails", "~> 1.1"
  gem "database_cleaner"
  gem "capybara", "~> 1.0.0"
  gem "launchy"
end

# group :development do
#   gem "tolk", :git => "git://github.com/cover/tolk.git"
# end
