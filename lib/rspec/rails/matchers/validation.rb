module RSpec::Rails::Matchers
  module Validation
    class IsValid < RSpec::Matchers::BuiltIn::BaseMatcher

      def initialize(scope)
        @scope = scope
      end

      def matches?(actual)
        @actual = actual
        @actual.valid?
      end

      def description
        "be valid"
      end

      # @api private
      def failure_message_for_should
        @actual.errors.full_messages
      end

      # @api private
      def failure_message_for_should_not
        "expected it to be invalid, but it was valid"
      end
    end

    # Calls valid?
    #
    # @example
    #
    #    model.should be_valid
    def be_valid
      IsValid.new(self)
    end
  end
end
