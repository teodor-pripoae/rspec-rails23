require 'action_controller'
require 'action_controller/test_case'

RSpec.configure do |config|
  config.add_setting :infer_base_class_for_anonymous_controllers, :default => false
end

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

      module ClassMethods
        # @private
        def controller_class
          described_class
        end

        # Supports a simple DSL for specifying behavior of ApplicationController.
        # Creates an anonymous subclass of ApplicationController and evals the
        # `body` in that context. Also sets up implicit routes for this
        # controller, that are separate from those defined in "config/routes.rb".
        #
        # @note Due to Ruby 1.8 scoping rules in anoymous subclasses, constants
        #   defined in `ApplicationController` must be fully qualified (e.g.
        #   `ApplicationController::AccessDenied`) in the block passed to the
        #   `controller` method. Any instance methods, filters, etc, that are
        #   defined in `ApplicationController`, however, are accessible from
        #   within the block.
        #
        # @example
        #
        #     describe ApplicationController do
        #       controller do
        #         def index
        #           raise ApplicationController::AccessDenied
        #         end
        #       end
        #
        #       describe "handling AccessDenied exceptions" do
        #         it "redirects to the /401.html page" do
        #           get :index
        #           response.should redirect_to("/401.html")
        #         end
        #       end
        #     end
        #
        # If you would like to spec a subclass of ApplicationController, call
        # controller like so:
        #
        #     controller(ApplicationControllerSubclass) do
        #       # ....
        #     end
        def controller(base_class = nil, &body)
          base_class ||= RSpec.configuration.infer_base_class_for_anonymous_controllers? ?
            controller_class :
            ApplicationController

          metadata[:example_group][:described_class] = Class.new(base_class) do
            def self.name; "AnonymousController"; end
          end
          metadata[:example_group][:described_class].class_eval(&body)

          with_routing do |set|
            set.draw do |map|
              map.resources :anonymous
              map.connect 'anonymous/:action', :controller => :anonymous
              map.connect 'anonymous/:action/:id', :controller => :anonymous
            end
          end
        end

        def with_routing(&route_set)
          around(:each) do |example|
            begin
              real_routes = ActionController::Routing::Routes
              ActionController::Routing.module_eval { remove_const :Routes }

              temporary_routes = ActionController::Routing::RouteSet.new
              ActionController::Routing.module_eval { const_set :Routes, temporary_routes }

              route_set.call temporary_routes
              example.run
            ensure
              if ActionController::Routing.const_defined? :Routes
                ActionController::Routing.module_eval { remove_const :Routes }
              end
              ActionController::Routing.const_set(:Routes, real_routes) if real_routes
            end
          end
        end

      end

      module BypassRescue
        def rescue_with_handler(exception)
          raise exception
        end
      end

      # Extends the controller with a module that overrides
      # `rescue_with_handler` to raise the exception passed to it.  Use this to
      # specify that an action _should_ raise an exception given appropriate
      # conditions.
      #
      # @example
      #
      #     describe ProfilesController do
      #       it "raises a 403 when a non-admin user tries to view another user's profile" do
      #         profile = create_profile
      #         login_as profile.user
      #
      #         expect do
      #           bypass_rescue
      #           get :show, :id => profile.id + 1
      #         end.to raise_error(/403 Forbidden/)
      #       end
      #     end
      def bypass_rescue
        controller.extend(BypassRescue)
      end

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

      included do
        subject { @controller }

        metadata[:type] = :controller

        before do
          @request = ActionController::TestRequest.new
          @response = ActionController::TestResponse.new

          if klass = self.class.controller_class
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
