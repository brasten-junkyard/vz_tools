#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

require File.dirname(__FILE__) + '/realm'
require File.dirname(__FILE__) + '/login'

module Vz
  module Connector
    class DirRealm < Realm
      attr_accessor :address, :port, :base_dn, :default_dn, :login

      attr_mapping :address,        './*[local-name()="address"]'
      attr_mapping :port,           './*[local-name()="port"]',     :type => :integer
      attr_mapping :base_dn,        './*[local-name()="base_dn"]'
      attr_mapping :default_dn,     './*[local-name()="default_dn"]'
      attr_mapping :login,          './*[local-name()="login"]',    :type => Login

      # Marshal up the attributes
      #
      def marshal_attributes( xml, options={} )
        super

        xml.address( self.address )
        xml.port( self.port )
        xml.base_dn( self.base_dn )
        xml.default_dn( self.default_dn )
        self.login.marshal( options.merge(:builder => xml) ) if self.login
      end

    end
  end
end
