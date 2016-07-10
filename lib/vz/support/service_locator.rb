#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

module Vz
  module Support
    class ServiceLocator

      def initialize( connection, eid, parent_eid )
        @connection = connection
        @eid        = eid
        @parent_eid = parent_eid
      end

      def services( service=:system )
        @connection.send( service, service_header() )
      end

      private

        def service_header
          ( @parent_eid == @eid ) ?
            nil : { :dst => { :host => @parent_eid } }
        end

    end
  end
end
