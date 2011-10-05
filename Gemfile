source :rubygems

gem "rails", "~> 3.1.0"
gem "will_paginate", "~> 3.0.pre2"
gem "haml"
gem "formtastic", "~> 2.0.0.rc1"
gem "friendly_id"
gem "rdiscount"
gem "state_machine"
gem "redis"
gem "hiredis" # for better Redis support
gem "routing-filter"
# for redis
gem "SystemTimer", :require => nil, :platform => :ruby_18
gem "jquery-rails"
gem "devise"

group :assets do
  gem "sass-rails", "~> 3.1.0"
  gem "uglifier"
  gem "compass", "0.12.0.alpha.0.22e2458", :git => "git://github.com/chriseppstein/compass.git", :branch => "rails31"
end

group :production do
  gem "pg"
end

group :test, :development do
  gem "rspec-rails"
  gem "ruby-debug", :platform => :ruby_18
  gem "ruby-debug19", :require => "ruby-debug", :platform => :ruby_19
  gem "sqlite3"
  gem "simplecov"
end

group :test do
  gem "spork", "> 0.9.0.rc"
  gem "shoulda-matchers", :git => "git://github.com/thoughtbot/shoulda-matchers.git"
  gem "capybara-webkit", :git => "git://github.com/thoughtbot/capybara-webkit.git"
  gem "factory_girl_rails", "~> 1.1.rc1"
  gem "database_cleaner"
  gem "launchy"
end

# group :development do
#   gem "tolk", :git => "git://github.com/cover/tolk.git"
# end
