#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

module Vz
  module Support
    class ArrayAssociation < Array

      def initialize( baseline )
        super

        @_baseline = self.dup
      end

      def changed?
        ( self != @_baseline ) || ( any? { |obj| obj.respond_to?(:changed?) && obj.changed? } )
      end

      def to_hash
        self.map { |i| i.respond_to?(:to_hash) ? i.to_hash : i }
      end

      def to_s
        self.map { |o| o.to_s }.join(', ')
      end

      def to_changed_connector_hash
        return nil unless all? { |o| o.respond_to?(:to_changed_connector_hash) }

        self.map { |obj| obj.to_changed_connector_hash }.compact
      end

    end
  end
end
