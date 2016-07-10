#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

require File.join( File.dirname(__FILE__), 'node' )
require File.join( File.dirname(__FILE__), 'connector', 'interface', 'service_proxy' )

module Vz

  # MasterNode represents the Node in a cluster of hardware nodes which acts
  # as the cluster's master node.
  #
  class MasterNode < Node

    # Setup the various things we need to override for a MasterNode
    #
    def initialize( *args )
      super

      redefine_connection_methods()
    end

    private

      # Kind of a message way of digging into a couple objects and redefining
      # a few things.
      #
      def redefine_connection_methods
        conn  = self.connection

        def conn.vzaenvm( *args )
          sp = Vz::Connector::Interface::ServiceProxy.new( self, :vzaenvm, *args )

          def sp.get_info(*args)
            @interface = :server_group
            return method_missing( :get_info, *args )
          ensure
            @interface = :vzaenvm
          end

          return sp
        end
      end # redefine

  end # class

end
