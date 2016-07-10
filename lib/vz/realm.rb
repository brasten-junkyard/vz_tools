#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

require File.dirname(__FILE__) + '/helper/active_vz'

module Vz
  class Realm
    include Vz::Helper::ActiveVz

    attr_writer :id, :realm_type, :name, :builtin,
                :address, :port, :base_dn, :default_dn, :login


    def id
      @id || ( @document ? REXML::XPath.first( @document, './*[local-name()="id"]' ).text : nil )
    end

    def realm_type
      @realm_type || ( @document ? REXML::XPath.first( @document, './*[local-name()="type"]' ).text : nil )
    end

    def login
      @login || ( @document ? REXML::XPath.first( @document, './*[local-name()="login"]' ) : nil )
    end

    # Marshal up the attributes
    #
    def marshal_attributes( xml, options={} )
      xml.id( self.id ) if self.id
      xml.realm_type( self.realm_type )
      xml.name( self.name )
      xml.builtin( self.builtin ) if self.builtin
      xml.address( self.address )
      xml.port( self.port )
      xml.base_dn( self.base_dn )
      xml.default_dn( self.default_dn )
      self.login.marshal( options.merge(:builder => xml) ) if self.login
    end

  end
end
