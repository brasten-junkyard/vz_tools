#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

require File.join( File.dirname(__FILE__), 'process' )

module Vz
  class ProcessList
    include Vz::Helper::ActiveVz

    attr_accessor :eid
    attr_accessor :locator
    attr_accessor :processes

    def processes( attribute=nil, direction=nil )
      names = REXML::XPath.match( @document, './*[local-name()="param_id"]/text()' )

      @document.get_elements('./*[local-name()="process"]').map { |process|
        Vz::Process.new(
          :eid        => self.eid,
          :locator    => self.locator,
          :names      => names,
          :document   => process
        )
      }.sort { |a, b| b.cpu_usage <=> a.cpu_usage }
    end

  end

  class Node

    def find_processes( params={} )
      eid = params[:eid] || self.eid
      pid = params[:pid]

      env = find_container_by_eid( eid )

      pid.nil? ? env.processes() : env.processes( :pid => pid )
    end
  end

end
