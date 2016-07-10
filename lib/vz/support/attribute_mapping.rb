#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

module Vz
  module Support
    module AttributeMapping

      def self.included(klass)
        klass.extend(MappingMethods)
      end

      module MappingMethods
        def attr_mapping( *args, &block )
          @_schema ||= Vz::Support::Schema.new

          if ( args.all? { |arg| arg.is_a?(Symbol) } && args.length > 1 )
            args.each do |arg|
              attr_mapping( arg )
            end
          else
            @_schema.attr_mapping( *args, &block )
            self.send( :attr_accessor, args.first.to_sym ) if self.kind_of?(Class)
          end
        end

        def schema
          @_schema
        end

        def schema_attributes
          @_schema.attributes
        end

        def inherited(subclass)
          subclass.instance_variable_set(:@_schema, @_schema.deep_copy) unless @_schema.nil?
        end

        def from_local_name( name )
          './*[local-name()="' + name + '"]'
        end
      end

    end
  end
end

require File.dirname(__FILE__) + '/schema'
