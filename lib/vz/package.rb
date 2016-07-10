#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

module Vz
  class Package
    include Vz::Helper::ActiveVz

    attr_remote :name
    attr_remote :platform, :path => [ :os, :platform ]
    attr_remote :summary
    attr_remote :description
    attr_remote :architecture, :path => [ :arch ]
    attr_remote :version
    attr_remote :path
    attr_remote :os_template
    attr_remote :cached
    attr_remote :uptodate

    def id
      self.name
    end

    def is_operating_system?
      self.os_template == '1'
    end

    def is_cached?
      self.cached == '1'
    end

    def is_uptodate?
      self.uptodate == '1'
    end

  end

  class Node

    # Retrieves a list of Operating System packages.
    #
    def os_packages
      results = self.connection.vzapackagem.list( :options => { :type => 'os' } )

      results.get_elements('./*[local-name()="package"]').map do |pkg|
        Vz::Package.new( :document => pkg )
      end
    end

    def find_package( options={} )
      pkg = { :name => options[:name] }
      pkg.merge!( :os_template => '1' ) if options[:type] == 'os'

      self.connection.vzapackagem.get_info( :packages => { :package => pkg } )
    end
  end
end
