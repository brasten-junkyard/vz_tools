#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

require 'ostruct'

module Vz
  module Support
    class SchemaAttribute
      attr_reader :xpath, :element_type, :array, :schema, :filter

      def initialize( xpath, options={} )
        @xpath        = xpath
        @element_type = options[:type]  || :auto
        @array        = options[:array] || false
        @schema       = options[:schema]
        @filter       = options[:filter]
      end

      def array?
        self.array
      end

    end
  end
end
