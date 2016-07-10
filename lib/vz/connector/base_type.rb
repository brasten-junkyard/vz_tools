#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

require 'base64'
require 'forwardable'
require File.dirname(__FILE__) + '/../support/attribute_mapping'
require File.dirname(__FILE__) + '/../support/marshaller'

module Vz
  module Connector
    class BaseType
      include Vz::Support::AttributeMapping
      extend Forwardable

      attr_accessor :document

      @@marshaller = Vz::Support::Marshaller

      class << self
        def unmarshal( xml, options={} )
          options[:class] = self

          @@marshaller.unmarshal( xml, options )
        end

        def schema_attributes
          self.class.schema_attributes
        end
      end

      def initialize( parameters={} )
        parameters.each_pair do |key, value|
          send("#{key}=".to_sym, value)
        end
      end

      def marshal( options={} )
        @@marshaller.marshal( self, options )
      end

      def marshal_attributes( xml, options={} )
        self.class.schema_attributes.each_pair do |key, val|
          obj = send(key.to_sym)
          if val.array? && obj.is_a?(Array)
            obj.each do |obj_value|
              xml.tag!(key.to_sym, obj_value)
            end
          else
            xml.tag!(key.to_sym, obj) unless obj.nil?
          end
        end
      end

      def merge( hash_or_object )
        return self.dup.merge!( hash_or_object )
      end

      def merge!( hash_or_object )
        if hash_or_object.kind_of?(Hash)
          hash_or_object.each_pair do |key, val|
            method = "#{key.to_s}=".to_sym

            send(method, val) if respond_to?(method)
          end
        else
          self.schema_attributes.each_key do |key|
            method = "#{key.to_s}=".to_sym

            send(method, hash_or_object.send(key.to_sym)) if hash_or_object.respond_to?(key.to_sym)
          end
        end

        return self
      end

      def default_interface
        :system
      end

      def local_name
        self.class.name.split('::').last.gsub(/[A-Z]/, '_\&').sub('_', '').downcase
      end

      def root_attributes( options={} )
        {}
      end

      def encode64( val )
        return nil if (val.nil? || val.empty?)

        Base64.encode64( val )
      end

      def decode64( val )
        return nil if (val.nil? || val.empty?)

        Base64.decode64( val )
      end

    end
  end
end
