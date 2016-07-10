#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

require 'vz/helper'
require 'vz/helper/active_vz'
require File.join( File.dirname(__FILE__), 'support', 'multiple_source_array' )
require File.join( File.dirname(__FILE__), 'support', 'array_association' )
require File.join( File.dirname(__FILE__), 'support', 'date_conversion' )

gem 'builder'
require 'builder'

module Vz

  # Container represents a VE in it's current state.
  #
  class Container
    include Vz::Helper::ActiveVz

    attr_accessor :node

    attr_remote   :eid
    attr_remote   :parent_eid
    attr_remote   :name,                :path => [ :virtual_config, :name ]
    attr_remote   :hostname,            :path => [ :virtual_config, :hostname ]
    attr_remote   :description,         :path => [ :virtual_config, :description ]
    attr_remote   :domain,              :path => [ :virtual_config, :domain ]
    attr_remote   :search_domains,      :path => [ :virtual_config, :search_domain ],
                                        :type => :array
    attr_remote   :qos
    attr_remote   :net_devices
    attr_remote   :architecture
    attr_remote   :operating_system
    attr_remote   :root_dir,            :path => [ :virtual_config, :ve_root ]
    attr_remote   :private_dir,         :path => [ :virtual_config, :ve_private ]
    attr_remote   :start_on_boot,       :path => [ :virtual_config, :on_boot ]
    attr_remote   :app_templates,       :path => [ :virtual_config, :template ]
    attr_remote   :distribution,        :path => [ :virtual_config, :distribution ]
    attr_remote   :disabled,            :path => [ :virtual_config, :disabled ]
    attr_remote   :offline_management,  :path => [ :virtual_config, :offline_management ]
    attr_remote   :iptables,            :path => [ :virtual_config, :iptables ]
    attr_remote   :ve_type,             :path => [ :virtual_config, :ve_type ]
    attr_remote   :reboot_allowed,      :path => [ :virtual_config, :allow_reboot ]
    attr_remote   :rate_bound,          :path => [ :virtual_config, :rate_bound ]
    attr_remote   :interface_rates
    attr_remote   :sample_configuration_id, :path => [ :virtual_config, :base_sample_id ]

    def id
      self.eid
    end

    def node_hostname
      self.node.hostname
    end

    def os_package
      self.node.find_package( :name => get_text( :virtual_config, :os_template, :name ), :type => 'os' )
    end

    def os_package=(pkg)
      set_text( :virtual_config, :os_template, :name, pkg.name )
    end

    def status
      Vz::Container::Status.new( :document => REXML::XPath.first( @document, './*[local-name()="status"]' ) )
    end

    def nameservers
      Vz::Support::MultipleSourceArray.new( self.net_devices.map { |nd| nd.nameservers } )
    end

    def ip_addresses
      @ip_addresses ||
        REXML::XPath.match( self.virtual_config, './*[local-name()="address"]/*[local-name()="ip"]/text()' ).to_a
    end

    # Returns whether or not this VE actually exists.
    #
    def exists?
      !( vzlist!.nil? )
    end

    def is_hardware_node?
      ( self.parent_eid || "" ).include?("00000")
    end

    # Returns true if VE is currently running.
    #
    def running?
      self.status == :running
    end

    def new_record?
      self.eid.nil?
    end

    def slm
      qos.property_for(:slmmemorylimit)
    end

    def memory
      preloaded_attributes[:memory] ||
        Vz::PerformanceData.new(
          services(:perf_mon).get(
            :eid_list => { :eid => self.eid },
            :class    => { :name => 'counters_vz_memory', :instance => nil }
          )
        ).memory_load
    end

    def cpu_load
      preloaded_attributes[:cpu_load] ||
        Vz::PerformanceData.new(
          services(:perf_mon).get(
            :eid_list => { :eid => self.eid },
            :class    => { :name => 'counters_vz_cpu', :instance => nil }
          )
        ).cpu_load
    end

    def net_stats
      end_time    = Time.now
      start_time  = Time.local( 2008, 1, 1 )

      services(:res_log).get_log(
        :eid => self.eid,
        :class        => { :name => 'counters_vz_net', :instance => nil },
        :start_date   => Vz::Support::DateConversion.from_date( start_time ),
#        :end_date     => Vz::Support::DateConversion.from_date( end_time ),
#        :period       => ( 60 * 60 ),
        :report_empty => nil
      )
    end

    def processes( options={} )
      pid = options[:pid]

      procs =
        Vz::ProcessList.new(
          :eid        => self.eid,
          :locator    => service_locator,
          :document   => services(:vzaproc_info).get( :eid => self.eid )
        ).processes()

      pid.nil? ? procs : procs.find { |proc| proc.pid.to_i == pid.to_i }
    end

    def kill_process( pid )
      services(:vzaprocessm).kill( :eid => self.eid, :pid => pid, :signal => 9 )
    end

    def save!
      new_record? ? create_container! : save_container!
    end

    # Execute an arbitrary command on container
    #
    def execute!( command )
      controller().execute!( command )
    end

    # Starts the VE
    #
    def start!
      services(:vzaenvm).start( :eid => self.eid )
    end

    # Stops the VE
    #
    def stop!
      services(:vzaenvm).stop( :eid => self.eid )
    end

    # Restarts the VE
    #
    def restart!
      services(:vzaenvm).restart( :eid => self.eid )
    end

#    def find_net_load_by_container( container )
#      Vz::CpuLoad.from_connector(
#        self.connection.perf_mon( header_for(container) ).get(
#          :eid_list => { :eid => container.eid },
#          :class    => { :name => 'counters_vz_cpu', :instance => nil }
#        )
#      )
#    end

    # Destroys the VE
    #
    def destroy!
      # TODO: implement destroy
    end

    # Suspends the VE
    #
    def suspend!
      # TODO: implement suspend
    end

    # Resumes a suspended VE
    #
    def resume!
      # TODO: implement resume
    end

    # Migrate a VZ to another hardware node
    #
    # Options:
    #   node:: Node object containing necessary information to
    #          move VE.
    #
    def migrate!( node )
      # TODO: implement migrate!
    end

    # Puts a file into the VE's private area
    #
    def puts_private!
      # TODO: implement puts-private
    end

    # Gets a file from the VE's private area
    #
    def gets_private
      # TODO: implement gets_private
    end

    # Returns log information for this VE
    #
    def get_log
      # TODO: implement get log
    end

    # Creates a temporary container identical to this one in case this
    # one is in need of maintenance.
    #
    # Returns the new VE that was created as a replacement for the
    # current one.
    #
    def repair
      # TODO: implement repair
    end

    # Stops and destroys temporary container created by 'repair.'
    #
    # Equivalent to calling stop! and destroy! on the VE that was returned
    # by #repair.
    #
    def stop_repair
      # TODO: implement stop_repair
    end

    # Provide an XML representation of this Container.
    #
    def to_xml( options={} )
      xml = options[:builder] || Builder::XmlMarkup.new

      xml.container do
        xml.eid(@eid)
        xml.status(@status)

        # From Settings
        xml.name(name)
        xml.description(description)
        xml.domain(domain)
        xml.hostname(hostname)
        xml.ip_addresses(ip_addresses.join(' '))
        xml.nameservers(nameservers.join(' '))
        xml.search_domains(search_domains.join(' '))
        xml.architecture(architecture)
        xml.operating_system(operating_system)
      end

      xml.target! unless options[:builder]
    end

    def changed_attributes
      ca = super()

      ca.delete(:node)
      ca.delete(:eid)
      ca.delete(:parent_eid)
      ca.delete(:status)

      ca
    end

    def set_preloaded_resources( performance_data )
      preloaded_attributes[:cpu_load] = performance_data.cpu_load
      preloaded_attributes[:memory]   = performance_data.memory_load
    end

    def preloaded_attributes
      @_preloaded_attributes ||= {}
    end

    def virtual_config
      REXML::XPath.first( @document, './*[local-name()="virtual_config"]' )
    end

    # Creates a default document for new Containers
    #
    def generate_document
      xml = Builder::XmlMarkup.new(:indent => 2)

      xml.env do
        xml.virtual_config do
        end
      end

      xml.target!
    end

    def build_persistence_document
      doc = REXML::Document.new( ( new_record? ? self.document : self.modified_document ).get_elements('./virtual_config').to_s ).root
      doc.name = "config"

      return doc
    end

    private

      def services( service=nil )
        service_locator.services( service )
      end

      def service_locator
        Vz::Support::ServiceLocator.new( self.node.connection, self.eid, self.parent_eid )
      end

      def create_default_net_devices!
        self.net_devices = [ Vz::NetDevice.new( :id => 'venet0' ) ]
      end

      def create_container!
        change_document!(
          services(:vzaenvm).create(
            :config => self.build_persistence_document()
          )
        )
      end

      def save_container!
        change_document!(
          services(:vzaenvm).set(
            :eid => self.eid,
            :config => self.build_persistence_document()
          )
        )
      end


  end

  class Container
    class Status
      include Vz::Helper::ActiveVz

      def status_code
        REXML::XPath.first( @document, "./*[local-name()='state']" ).text.to_i
      end

      def ==(val)
        ( val.to_i == self.to_i ) || ( val.to_sym == self.to_sym )
      end

      def to_sym
        case self.status_code
        when 6
          :running
        when 3
          :stopped
        else
          :unknown
        end
      end

      def to_i
        self.status_code
      end

      def to_s
        self.to_sym.to_s.capitalize
      end

    end
  end
end
