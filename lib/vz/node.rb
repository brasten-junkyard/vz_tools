#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

require 'vz/helper'
require File.join( File.dirname(__FILE__), 'connector' )

module Vz

  # Top-level object for VzTools.  Represents a hardware node.
  #
  class Node
    include Vz

    attr_reader :hostname

    def initialize( hostname='localhost', options={} )
      @hostname             = hostname
      @connection           = nil
      @cluster              = options.delete(:cluster)
      @connection_options   = options
    end

    # Builds a new container from the provided parameters but
    # does not actually create it.
    #
    # Calling #save! on result would create the container,
    # however.
    #
    def build_container( params={} )
      Vz::Container.new( params.merge( :node => self ) )
    end

    # Creates a new container from the provided parameters.
    #
    # Required params:
    # - name
    # - os_package
    #
    def create_container!( options={} )
      env = Vz::Container.new( params.merge( :node => self ) )
      env.save!

      return env
    end

    # Find an container by specified eid
    #
    def find_container_by_eid( eid )
      response = connection.vzaenvm.get_info( :eid => eid )

      response.nil? ?
        nil : Container.new( :node => self, :document => response )
    end

    def containers(*args)
      options = args.last.kind_of?(Hash) ? args.pop : {}
      eids    = options[:eid]

      call_params = { :status => nil, :config => nil }
      call_params.merge!( :eid => eids ) unless eids.nil?

      envs =
        self.connection.vzaenvm.get_info( call_params ).map { |result|
          Container.new( :node => self, :document => result )
        }.find_all { |f| !f.is_hardware_node? }


      if ( [options[:include]].flatten.include?(:resources) )
        resources = self.resources( envs )

        envs.each do |env|
          env.set_preloaded_resources( resources.performance_data_for( env.eid ) )
        end
      end

      return envs
    end

    def resources( containers )
      parents = containers.map { |e| e.parent_eid }.uniq

      msgs =
        parents.map { |parent_eid|
          self.connection.perf_mon( :dst => { :host => parent_eid } ).get(
            :eid_list => {
              :eid => containers.find_all { |f| f.parent_eid == parent_eid }.map { |m| m.eid }
            },
            :class => [
              { :name => 'counters_vz_cpu', :instance => nil },
              { :name => 'counters_vz_memory', :instance => nil }
            ]
          )
        }

      return ResourceInfo.new( msgs.flatten.find_all { |m| !m.kind_of?(String) } )
    end

    def eid
      @connection.eid
    end

    def connection
      @connection ||= Vz::Connector::Interface::Connection.new( self.hostname, @connection_options )
    end

  end
end
