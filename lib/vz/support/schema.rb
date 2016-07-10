#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

require File.dirname(__FILE__) + '/schema_attribute'
require File.dirname(__FILE__) + '/schema_collector'

module Vz
  module Support
    class Schema
      attr_reader :attributes

      def initialize
        @attributes = {}
      end

      def attr_mapping( name, *args, &block )
        xpath   = ( args.first.is_a?(String) ? args.shift : from_local_name(name.to_s) )
        options = args.first.is_a?(Hash) ? args.shift : {}

        if block_given?
          add_schema_to_options!( options )

          SchemaCollector.new( self, options[:schema] ).instance_eval(&block)
        end

        self.attributes[name.to_sym] = Vz::Support::SchemaAttribute.new( xpath, options )
      end

      def deep_copy
        copy = self.dup
        copy.instance_variable_set(:@attributes, copy.attributes.dup)
        copy.attributes.each_pair do |key, value|
          copy.attributes[key] = value.dup

          value.schema = value.schema.deep_copy if value.schema
        end

        copy
      end

      private

        def add_schema_to_options!( options )
          return if options[:schema]

          klass = options[:type]

          if ( klass.respond_to?(:schema) && !klass.schema.nil? )
            options[:schema] = klass.schema.deep_copy
          else
            options[:schema] = Schema.new
          end
        end

        def from_local_name( name )
          './*[local-name()="' + name + '"]'
        end

    end
  end
end
