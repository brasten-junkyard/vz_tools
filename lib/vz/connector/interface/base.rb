#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

require 'builder'

module Vz
  module Connector
    module Interface

      class Base
        attr_reader :connection

        def initialize( connection )
          @connection = connection
        end

        def do_request!( message )

        end

        def parse( response )
          return response
        end

        protected

          def with_envelope!
            xml = Builder::XmlMarkup.new( :indent => 2 )
            xml.packet( :version => "4.0.0", :id => Time.now.to_i ) do
              xml.data do
                yield(xml)
              end
            end
          end
      end
    end
  end
end
