#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

require 'ostruct'

module Vz
  module Support

    # MappedStruct is basically a last-resort for holding data who's type
    # we were unable to determine.
    #
    # Provides basic marshalling, but relies on the Marshaller to feed us
    # data for unmarshalling, as we have no schema to work with.
    #
    class MappedStruct < OpenStruct

      def initialize( hash={} )
        hash.each_pair do |key, val|
          case val
          when Hash
            hash[key] = MappedStruct.new( val )
          when Array
            hash[key] = val.map { |v| v.kind_of?(Hash) ? MappedStruct.new( v ) : v }
          else
            val
          end
        end

        super( hash )
      end

      def id=(val)
        @table[:id] = val
      end

      def id
        @table[:id]
      end

      def type
        @table[:type]
      end

      def sleep=(val)
        @table[:sleep] = val
      end

      def sleep
        @table[:sleep]
      end

      # Marshals this object into xml.
      #
      # Making a bit of a laziness-motivated assumption that you will in fact
      # be supplying a :builder option.  Even though it's optional, it's not.
      #
      # This is because I can't imagine any reason you'd be serializing this
      # object as the top-level message.
      #
      def marshal( options={} )
        xml = options[:builder]

        @table.each_pair do |key, value|
          if value.is_a?( Array )
            if value.empty?
              do_xml!( xml, key, nil )
            else
              value.each { |each_value| do_xml!( xml, key, each_value ) }
            end
          elsif value.is_a?(REXML::Element)
            xml << value.to_s
          else
            do_xml!( xml, key, value )
          end
        end
      end

      def to_hash
        hash = {}
        @table.each_pair do |k, v|
          hash[k] = ( v.respond_to?(:to_hash) ? v.to_hash : v )
        end
      end

      private

        def do_xml!( xml, key, value )
          case value
          when MappedStruct
            xml.tag!(key) do
              value.marshal( :builder => xml )
            end
          else
            xml.tag!(key, value.to_s)
          end
        end

    end # class
  end # module
end # module
