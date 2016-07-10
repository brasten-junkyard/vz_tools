#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

require File.join( File.dirname(__FILE__), 'helper', 'active_vz' )

module Vz
  class Realms < Array
    def initialize( params={} )
      realms = params[:document].get_elements('./realm').to_a.map do |realm|
        Realm.new( :document => realm )
      end

      super(realms)
    end

    def system_realm
      self.find { |r| puts r.realm_type; r.realm_type == "0" }
    end

  end
end
