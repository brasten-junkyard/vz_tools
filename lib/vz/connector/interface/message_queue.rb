#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

require File.dirname(__FILE__) + '/../packet'

module Vz
  module Connector
    module Interface
      class MessageQueue

        def initialize
          @mutex      = Mutex.new
          @queue = {}
          @ordered_queue = []
        end

        def <<( message )
          Vz.log("Received Message.")
          Vz.log( :debug,  message )

          packet = nil
          packet = Packet.unmarshal( message )

          Vz.log( :debug,  "Unmarshalled to : #{packet.inspect}" )
          msg = ( packet.messages.size == 1 ? packet.messages.first : packet.messages )
          msg = packet if packet.acknowledgement?

          Vz.log( "MSG == #{msg.inspect}" )
          Vz.log( "packet.message_id == #{packet.message_id}")

          @mutex.synchronize do
            ( @queue[packet.message_id] ||= [] ) << msg
            @ordered_queue << msg
          end

          Vz.log( :debug,  "Queue           : #{@ordered_queue.size} items" )
        end

        def next_message
          msg = @ordered_queue.shift
          return nil if msg.nil?

          @mutex.synchronize do
            @queue.values.each do |msg_queue|
              msg_queue.delete( msg )
            end

            return msg
          end
        end

        def message_for_id( msg_id )
          return nil if ( @queue[msg_id].nil? || @queue[msg_id].empty? )

          @mutex.synchronize do
            msg = @queue[msg_id].shift
            @ordered_queue.delete(msg)

            return msg
          end
        end

      end
    end
  end
end
