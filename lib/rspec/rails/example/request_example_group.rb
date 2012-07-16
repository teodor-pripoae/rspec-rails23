require 'action_controller'
require 'action_controller/test_case'
require 'action_controller/integration'

module RSpec
  module Rails
    module RequestExampleGroup
      extend ActiveSupport::Concern
      include RailsExampleGroup
      include ActionController::TestCase::Assertions
      include ActionController::Integration::Runner
      include RSpec::Rails::Matchers::RedirectTo
      include RSpec::Rails::Matchers::RenderTemplate

      included do
        metadata[:type] = :request
      end
    end
  end
end
