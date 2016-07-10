#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

module Vz
  module Support
    class QosArray < ArrayAssociation

      def property_for( key )
        self.find { |qos| qos.id.to_s == key.to_s } ||
          ( self << Vz::Qos.new(:id => key.to_s); self.property_for( key.to_sym ) )
      end

    end
  end
end
