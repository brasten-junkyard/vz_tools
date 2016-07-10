#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

module Vz

  # Represents QoS statistics.
  #
  # Extends Stats and adds attributes: total / soft_limit / hard_limit / failures
  #
  class Qos
    include Vz::Helper::ActiveVz

    def id
      REXML::XPath.first( @document, './*[local-name()="id"]' ).text
    end

    def current
      REXML::XPath.first( @document, './*[local-name()="cur"]' ).text.to_i
    end

    def hard_limit
      REXML::XPath.first( @document, './*[local-name()="hard"]' ).text.to_i
    end

    def soft_limit
      REXML::XPath.first( @document, './*[local-name()="soft"]' ).text.to_i
    end

    # If there are ANY changes, we'll need to send back ALL attributes.
    #
    def changed_attributes
      super().empty? ? [] : [:id, :soft_limit, :hard_limit]
    end

    def to_connector_hash
      hash = {}
      hash[:id] = self.id
      hash[:soft] = self.soft_limit
      hash[:hard] = self.hard_limit

      hash
    end

  end
end
