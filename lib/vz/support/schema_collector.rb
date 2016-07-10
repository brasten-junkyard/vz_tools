#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

require File.dirname(__FILE__) + '/attribute_mapping'

module Vz
  module Support
    class SchemaCollector
      include Vz::Support::AttributeMapping::MappingMethods

      def initialize( target, schema )
        @_target = target
        @_schema = schema
      end

      def method_missing( sym, *args, &block )
        @_target.send(sym, *args, &block)
      end

    end
  end
end
