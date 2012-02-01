module Rspec
  module Rails23

    module Configuration

      def rails
        self
      end

      def escaped_path(*parts)
        Regexp.compile(parts.join('[\\\/]'))
      end
      private :escaped_path

      def enable_active_record_transactional_support(filter_options={})
        RSpec.configuration.extend(::Rspec::Rails23::TransactionalDatabaseSupport, filter_options)
      end

      def enable_helper_support(filter_options={})
        RSpec.configuration.extend(::Rspec::Rails23::Helpers, filter_options)
      end

      def enable_controller_support(filter_options={})
        RSpec.configuration.extend(::Rspec::Rails23::Controllers, filter_options)
      end

      def enable_rails_specific_mocking_extensions(filter_options={})
        case RSpec.configuration.mock_framework.framework_name
        when :mocha
          require 'rspec/rails23/mocking/with_mocha'
          RSpec.configuration.include(::Rspec::Rails23::Mocking::WithMocha, filter_options)
        when :rr
          require 'rspec/rails23/mocking/with_rr'
          RSpec.configuration.include(::Rspec::Rails23::Mocking::WithRR, filter_options)
        end
      end

      def enable_reasonable_defaults!
        enable_active_record_transactional_support
        enable_helper_support :type => :helper, :example_group => {
          :file_path => escaped_path(%w[spec helpers])
        }
        enable_controller_support :type => :controller, :example_group => {
          :file_path => escaped_path(%w[spec controllers])
        }
        enable_rails_specific_mocking_extensions
      end
    end
  end
end

::RSpec::Core::Configuration.send(:include, ::Rspec::Rails23::Configuration)
