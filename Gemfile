source :gemcutter

gem "rails", "=3.0.1"
gem "sqlite3-ruby", :require => "sqlite3"
gem "will_paginate"
gem "mongo_mapper"
gem "bson_ext"
gem "haml"
gem "bundler", ">=1.0.0"
gem "formtastic"
gem "friendly_id", "~> 3.1"
gem "rdiscount"

group :staging do
  gem "pg"
  gem "thin"
end 

group :test do
  gem "webrat"
  gem "test-unit"
  gem "rspec", ">=2.0.0.rc"
  gem "rspec-rails", ">=2.0.0.rc"
  gem "faker"
  gem "factory_girl_rails"
end

group :development do
  gem "nifty-generators"
  gem "factory_girl"
end

group :cucumber do
  gem "cucumber-rails"
  gem "pickle"
  gem "database_cleaner"
  gem "capybara", "=0.3.9"
  gem "factory_girl"
  gem "launchy"
  gem "selenium-webdriver"
end

