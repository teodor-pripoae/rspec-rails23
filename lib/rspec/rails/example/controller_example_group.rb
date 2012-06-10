require 'action_controller'
require 'action_controller/test_case'

module RSpec
  module Rails
    module ControllerExampleGroup
      extend ActiveSupport::Concern
      include RailsExampleGroup
      include ActionController::TestProcess
      include ActionController::TestCase::Assertions
      include ActionController::TestCase::RaiseActionExceptions
      include RSpec::Rails::ViewRendering
      include RSpec::Rails::Matchers::RenderTemplate
      include RSpec::Rails::Matchers::RedirectTo

      attr_reader :request, :response, :controller

      def route_for(options)
        ActionController::Routing::Routes.reload if ActionController::Routing::Routes.empty?
        ActionController::Routing::Routes.generate(options)
      end

      def params_from(method, path)
        ActionController::Routing::Routes.reload if ActionController::Routing::Routes.empty?
        ActionController::Routing::Routes.recognize_path(path, :method => method)
      end

      def set_raw_post_data(body)
        request.env['RAW_POST_DATA']=body
      end

      # @private
      def controller_class
        described_class
      end

      included do
        subject { @controller }

        metadata[:type] = :controller

        before do
          @request = ActionController::TestRequest.new
          @response = ActionController::TestResponse.new

          if klass = controller_class
            @controller ||= klass.new rescue nil
          end

          if @controller
            @controller.request = @request
            @controller.params = {}
            @controller.send(:initialize_current_url)
          end
        end

        after(:each) do
          request.env.delete('RAW_POST_DATA')
        end
      end
    end
  end
end

module ActionController
  class Base
    include TestCase::RaiseActionExceptions
    include RSpec::Rails::ViewRendering::RenderOverrides
  end
end
