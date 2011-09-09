#config/initializers/sass.rb
require 'compass/util'
require 'compass/browser_support'
require 'compass/sass_extensions'
require 'compass/version'
require 'compass/errors'
Sass::Engine::DEFAULT_OPTIONS[:load_paths].tap do |load_paths|
  load_paths << "#{Rails.root}/assets/stylesheets"
  load_paths << "#{Rails.root}/assets/images"
  load_paths << "#{Gem.loaded_specs['compass'].full_gem_path}/frameworks/blueprint/stylesheets"
  load_paths << "#{Gem.loaded_specs['compass'].full_gem_path}/frameworks/compass/stylesheets"
end