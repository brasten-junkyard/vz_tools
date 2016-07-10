#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

require 'thread'
require 'io/wait'

require File.join( File.dirname(__FILE__), 'service_proxy' )
require File.join( File.dirname(__FILE__), 'message_queue' )

module Vz
  module Connector
    module Interface

      class Connection
        @@allowed_interfaces = %w(system alertm authm backup_storagem backupm clusterm computerm data_storagem devm dirm
                                  env_samplem envm event_log filer firewallm intrastructurem licensem mailer relocator
                                  networkm op_log pager perf_mon packagem proc_info processm res_log resourcem scheduler
                                  securitym servicem sessionm userm vzaenvm vzaproc_info vzaprocessm vzapackagem server_group)

        attr_reader :eid
        attr_reader :hostname
        attr_reader :port
        attr_reader :username
        attr_reader :password

        def initialize( hostname, options={} )
          @mutex          = Mutex.new
          @hostname       = hostname
          @port           = options[:port] || 4433
          @username       = options[:username] || 'root'
          @password       = options[:password]
          @queue          = MessageQueue.new
          @handler        = nil

          @reader_thread  = start_reader!

          do_login!
        end

        # Sends a message and waits for a response.
        #
        # Accepts a symbol indicating the desired "interface"
        # for message (ie: :system / :authm / etc ), plus
        # an object which responds to #marshal and returns
        # XML.
        #
        # Interface argument can be omitted and will default
        # to message's default_interface.
        #
        def send_message!( *args, &block )
          options   = args.last.kind_of?(Hash) ? args.pop : {}
          message   = args.pop
          interface = args.pop || message.default_interface

          send_packet!(
            Packet.new(
              :interface  => interface,
              :messages   => message,
              :header     => options[:header]
            )
          )
        end

        def send_packet!( packet, &block )
          msg_id = packet.message_id

          send_data!( packet.marshal )
          wait_for_response_for( msg_id ) unless block_given?
        end

        def send_data!( xml )
          Vz.log( :debug, " Sending ----> #{xml}")
          @handler.send_data( xml + "\0" )
        end

        def next_message
          loop do
            msg = @queue.next_message

            if msg: return msg
#            else sleep(0.1)
            end
          end
        end

        def wait_for_response_for( msg_id )
          Vz.log( "@queue.message_for_id( #{msg_id} )")

          loop do
            msg = @queue.message_for_id( msg_id )

            if ( !msg.nil? && msg.respond_to?(:error) && !msg.error.nil? )
              raise ConnectorError.for( msg.error.code ), msg.error.message
            elsif !msg.nil?
              return msg
            end
            Thread.pass
          end
        end

        def vocabulary
          ( @vocabulary ||= {} )[:operators]
        end

        def join
          @reader_thread.join
        end

        def method_missing( sym, *args, &block )
          if @@allowed_interfaces.include?( sym.to_s )
            ServiceProxy.new( self, sym, *args )
          else
            super
          end
        end

        private

          # TODO: Raise Errors on Login problems
          #
          def do_login!
            puts "VZTools: Connection Established..."

            ack     = next_message
            @eid    = ack.eid

            realms  = Vz::Realms.new( :document => self.system.get_realm )
            system_realm = realms.system_realm

            self.system.login( :name => Vz.encode( @username ), :password => Vz.encode( @password ), :realm => system_realm.id )
          end

          def do_voc!
            ( @vocabulary ||= {} )[:operators] = self.system.get_vocabulary( :category => 'operators' )
          end

          def start_reader!
            thread =
              Thread.new( self.hostname, self.port ) do |host, port|
                EventMachine.run {
                  Thread.current[:handler] = EventMachine.connect(host, port, Vz::Connector::Interface::MessageHandler)
                }
              end

            Thread.pass

            @handler = thread[:handler]
            @handler.set_message_queue( @queue )

            return thread
          end

      end # class


      # MessageHandler module for EventMachine
      #
      module MessageHandler

        def set_message_queue( queue )
          @queue = queue
        end

        def post_init
          @data = ""
        end

        def append_data( data )
          @data << data.gsub("\0", '')
        end

        def send_data_to_queue!
          Vz.log( :debug, "Adding message to queue... #{@data.inspect}")
          @queue << @data
          @data = ""
        end

        def receive_data( data )
          messages          = data.split("</packet>\n")
          trailing_message  = messages.pop

          messages.each { |msg| append_data( msg + "</packet>\n" ); send_data_to_queue! }
          append_data( trailing_message )
        end

      end # message-handler

    end # module
  end # module
end # module
