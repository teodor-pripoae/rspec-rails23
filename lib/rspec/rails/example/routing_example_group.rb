require 'action_controller'
require 'action_controller/test_case'

module RSpec::Rails
  module RoutingExampleGroup
    extend ActiveSupport::Concern
    include RSpec::Rails::RailsExampleGroup
    include ActionController::TestCase::Assertions
    include RSpec::Rails::Matchers::RoutingMatchers
    include RSpec::Rails::Matchers::RoutingMatchers::RouteHelpers
    class RoutingController < ActionController::Base; end

    included do
      metadata[:type] = :routing
    end
  end
end
