#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

module Vz
  module Connector
    module Interface

      # ServiceProxy acts as a Proxy to the services.
      #
      # Kinda obvious, eh?
      #
      class ServiceProxy

        def initialize( connection, interface, *args )
          @connection   = connection
          @interface    = interface
          @header       = args.shift || nil
        end

        #
        def method_missing( sym, *args, &block )
          options     = args.last.kind_of?(Hash) ? args.last : {}

          obj =
            begin
              eval("Vz::Connector::#{classize(sym)}").new( *args )
            rescue NameError
              arguments = args.pop
              arguments.is_a?(Hash) ? { sym => arguments } : sym
            end

          @connection.send_message!( @interface.to_sym, obj, :header => @header, &block )
        end

        private

          def classize( sym )
            str = sym.to_s
            str.capitalize.gsub(/_(\w)/) { |s| $1.to_s.upcase }
          end

      end
    end
  end
end
