require 'active_support/concern'
require 'rspec/core'

RSpec::configure do |c|
  c.backtrace_clean_patterns << /vendor\//
  c.backtrace_clean_patterns << /lib\/rspec\/rails/
  c.backtrace_clean_patterns << /lib\/rspec\/rails23/
end

require 'rspec/rails/view_rendering'
require 'rspec/rails/matchers'
require 'rspec/rails/example'
require 'rspec/rails23/configuration'
require 'rspec/rails23/transactional_database_support'
#require 'rspec/rails23/controllers'
require 'rspec/rails23/helpers'
require 'rspec/rails23/extensions/active_record'
require 'rspec/rails23/mocking/model_stubber'

module Rspec
  module Rails23
    class IllegalDataAccessException < StandardError; end
  end
end

