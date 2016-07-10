#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

require File.dirname(__FILE__) + '/base_type'
require File.join( File.dirname(__FILE__), '..', 'support', 'mapped_struct' )

module Vz
  module Connector
    class Packet < BaseType

      attr_writer   :interface
      attr_writer   :message_id
      attr_writer   :eid
      attr_accessor :header

      class << self
        def unmarshal( xml )
#          @_old_keep_blanks_value = XML::Parser.default_keep_blanks
#          XML::Parser.default_keep_blanks = false

          return Packet.new( :document => REXML::Document.new( xml ).root )
#        ensure
#          XML::Parser.default_keep_blanks = ( @_old_keep_blanks_value || false )
        end

        def generate_message_id
          chars = ('A'..'Z').to_a + ('a'..'z').to_a + (0..9).to_a

          (0..20).map { |m| chars[rand(chars.length)] }.join
        end
      end

      def initialize(*args)
        super
        self.message_id = Packet.generate_message_id() unless @document
      end

      def eid
        @eid || ( @document ? @document.text('./data/eid') : nil )
      end

      def message_id
        @message_id || ( @document ? REXML::XPath.first( @document, './@id' ).value : nil )
      end

      def interface
        @interface || ( @document ? REXML::XPath.first( @document, 'local-name(./data/*)' ).to_sym : nil )
      end

      def messages
        @messages ||= ( @document ? @document.get_elements( './data/*/*' ).to_a : [] )
      end

      def messages=(val)
        self.messages.concat( [val].flatten )
      end

      def acknowledgement?
        interface == :ok
      end

      def root_attributes( options={} )
        { :id => ( self.message_id ||= Packet.generate_message_id() ), :version => ( options[:version] || '4.0.0' ) }
      end

      def marshal_attributes( xml, options={} )
        xml.target(self.interface.to_s) unless ( self.interface == :system )
        if self.header
          Vz::Support::MappedStruct.new( self.header ).marshal( :builder => xml )
        end

        Vz.log( "Messages: #{self.messages.inspect}" )

        xml.data do
          xml.tag!(self.interface.to_s) do
            self.messages.each do |message|
              message =
                case message
                when Symbol
                  Vz::Support::MappedStruct.new( message => {} )
                when Hash
                  Vz::Support::MappedStruct.new( message )
                else
                  message
                end

              message.marshal( :builder => xml ) if message.respond_to?(:marshal)
            end
          end
        end
      end

    end
  end
end
