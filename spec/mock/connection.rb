#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

module Vz
  module Connector
    module Interface
      class Connection

        def initialize( hostname, options={} )
          @hostname = hostname
          @options  = options
        end

        def send_packet!( packet )
          puts "SEND_PACKET: #{packet.inspect}"

          return build_response_for( packet )
        end


        private
          def build_response_for( packet )
            case packet.interface
            when :vzaenvm

              case packet.messages.first
              when :get_list
                build_container_list()

              when :get_info
                build_container_info()

              end
            end
          end

          def build_container_list
            ['000000-000000-111111-222222']
          end

          def build_container_info
            Env.new(
              :eid        => '000000-000000-111111-222222',
              :parent_eid => '000000-000000-111111-555555',
              :status     => EnvStatus.new(
                :state => 1)

            )
          end


      end
    end
  end
end
