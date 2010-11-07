require 'capybara/rails'
require 'capybara/dsl'

module RSpec::Rails
  module IntegrationExampleGroup
    extend ActiveSupport::Concern

    include RSpec::Rails::TestUnitAssertionAdapter
    include ActionDispatch::Assertions

    include RSpec::Rails::RailsExampleGroup
    include RSpec::Rails::ViewRendering
    include RSpec::Matchers
    include RSpec::Rails::Matchers::RedirectTo
    include RSpec::Rails::Matchers::RenderTemplate
    include RSpec::Rails::Matchers::RoutingMatchers

    module InstanceMethods
      def app
        ::Rails.application
      end

      def last_response
        page
      end
    end

    included do
      before do
        @router = ::Rails.application.routes
      end
    end

    RSpec.configure do |c|
      c.include self, :example_group => { :file_path => /\bspec\/integration\// }
    end
  end
end

