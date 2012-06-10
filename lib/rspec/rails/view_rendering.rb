RSpec.configure do |config|
  # This allows us to expose `render_views` as a config option even though it
  # breaks the convention of other options by using `render_views` as a
  # command (i.e. render_views = true), where it would normally be used as a
  # getter. This makes it easier for rspec-rails users because we use
  # `render_views` directly in example groups, so this aligns the two APIs,
  # but requires this workaround:
  config.add_setting :rendering_views, :default => false

  def config.render_views=(val)
    self.rendering_views = val
  end

  def config.render_views
    self.rendering_views = true
  end

  def config.render_views?
    rendering_views
  end
end

require 'action_controller'
require 'action_view'
require 'action_view/test_case'

module RSpec
  module Rails
    module ViewRendering
      extend ActiveSupport::Concern

      attr_accessor :controller

      module ClassMethods
        def metadata_for_rspec_rails
          metadata[:rspec_rails] = metadata[:rspec_rails] ? metadata[:rspec_rails].dup : {}
        end

        # @see RSpec::Rails::ControllerExampleGroup
        def render_views(true_or_false=true)
          metadata_for_rspec_rails[:render_views] = true_or_false
        end

        # @api private
        def render_views?
          metadata_for_rspec_rails[:render_views] || RSpec.configuration.render_views?
        end
      end

      # @api private
      def render_views?
        self.class.render_views? || !controller.class.respond_to?(:view_paths)
      end

      module TemplateIsolationExtensions
        def file_exists?(ignore); true; end

        def render_file(*args)
          @first_render ||= args[0] unless args[0] =~ /^layouts/
        end
      end

      module RenderOverrides
        def render(options=nil, extra_options={}, &block)
          puts "in overridden render!"
          unless block_given?
            unless rendering_views?
              @template.extend TemplateIsolationExtensions
            end
          end

          super
        end
      end
    end
  end
end

#module ActionView
  #class Base
    #alias_method :initialize_without_template_tracking, :initialize
    #def initialize(*args)
      #@_rendered = { :template => nil, :partials => Hash.new(0) }
      #initialize_without_template_tracking(*args)
    #end
  #end

  #module Renderable
    #alias_method :render_without_template_tracking, :render
    #def render(view, local_assigns = {})
      #if respond_to?(:path) && !is_a?(InlineTemplate)
        #rendered = view.instance_variable_get(:@_rendered)
        #rendered[:partials][self] += 1 if is_a?(RenderablePartial)
        #rendered[:template] ||= self
      #end
      #render_without_template_tracking(view, local_assigns)
    #end
  #end
#end
