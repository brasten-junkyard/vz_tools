#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

require File.dirname(__FILE__) + '/base'

module Vz
  module Connector
    module Interface

      # Adheres to the Virtuozzo 4 System interface
      #
      class System < Base

        def subscribe
          raise_unimplemented_error!
        end

        def unsubscribe
          raise_unimplemented_error!
        end

        def cancel
          raise_unimplemented_error!
        end

        def get_state
          raise_unimplemented_error!
        end

        def get_configuration
          raise_unimplemented_error!
        end

        def get_version
          raise_unimplemented_error!
        end

        def get_realm
          connection.send_request( with_envelope! { |xml| xml.get_realm } )
        end

        def register_client
          raise_unimplemented_error!
        end

        def count_registered
          raise_unimplemented_error!
        end

        def get_vocabulary
          raise_unimplemented_error!
        end

        def ping
          raise_unimplemented_error!
        end

        def connect
          raise_unimplemented_error!
        end

        def close
          raise_unimplemented_error!
        end

        def distribute
          raise_unimplemented_error!
        end

        def uninstall
          raise_unimplemented_error!
        end

        def get_plugins
          raise_unimplemented_error!
        end

        def get_eid
          raise_unimplemented_error!
        end

        def login
          raise_unimplemented_error!
        end

        def generate_pass
          raise_unimplemented_error!
        end

        def configuration
          raise_unimplemented_error!
        end

        def with_envelope!
          super do |xml|
            xml.system do
              yield(xml)
            end
          end
        end

      end

    end
  end
end
