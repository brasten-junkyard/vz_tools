#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

module Vz
  module Connector
    module Factory
      class RealmFactory

        class << self
          def get_class_for_element( element )
            Vz.log( :debug, "get_class: #{element.to_s}")
            realm_type = element.find_first('./*[local-name()="type"]/text()').to_s
            Vz.log( :debug, "type ==== #{realm_type}")


            return ( realm_type == '1' ) ? Vz::Connector::DirRealm : Vz::Connector::Realm
          end
        end

      end
    end
  end
end
