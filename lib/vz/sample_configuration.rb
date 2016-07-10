#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

require 'vz/helper'
require 'vz/helper/active_vz'
require File.join( File.dirname(__FILE__), 'support', 'multiple_source_array' )
require File.join( File.dirname(__FILE__), 'support', 'array_association' )
require File.join( File.dirname(__FILE__), 'support', 'qos_array' )
require File.join( File.dirname(__FILE__), 'support', 'date_conversion' )

gem 'builder'
require 'builder'

module Vz
  class SampleConfiguration
    include Vz::Helper::ActiveVz

    attr_remote   :id
    attr_remote   :name
    attr_remote   :comment
    attr_remote   :vt

    attr_remote   :type
    attr_remote   :net_devices
    attr_remote   :qos
    attr_remote   :offline_management
    attr_remote   :on_boot
    attr_remote   :slm_mode

    def nameservers
      Vz::Support::MultipleSourceArray.new( self.net_devices.map { |nd| nd.nameservers } )
    end

    def slm
      qos.property_for(:slmmemorylimit)
    end

    def disk_space
      qos.property_for(:diskspace)
    end

    def disk_inodes
      qos.property_for(:diskinodes)
    end

    def cpu_units
      qos.property_for(:cpuunits)
    end

    def cpu_limit
      qos.property_for(:cpulimit)
    end

    def net_devices=( arr )
      @net_devices =
        Vz::Support::ArrayAssociation.new(
          arr.map { |nd| Vz::NetDevice.new( nd.to_model_hash() ) }
        )
    end

    def qos=(val)
      return nil if val.nil?

      @qos =
        Vz::Support::QosArray.new(
          val.map { |v| (v.respond_to?(:to_model_hash) ? Qos.new( v.to_model_hash() ) : v) }
        )
    end

  end # SampleConfiguration

  module Adapter
    module SampleConfiguration

      def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
      end

      module InstanceMethods
        def to_changed_connector_hash
          hash = new_conditional_hash()

          hash.add_value(:id, self.id)
          hash.add_value(:name, self.name)
          hash.add_value(:comment, self.comment)

          conf_hash = new_conditional_hash()
          conf_hash.add_value(:type, self.type)
          conf_hash.add_value(:offline_management, self.offline_management)
          conf_hash.add_value(:net_device, self.net_devices.to_changed_connector_hash())
          conf_hash.add_value(:qos, self.qos.to_changed_connector_hash())

          hash.add_value(:env_config, conf_hash)
          hash[:vt_version] = self.vt.to_hash

          return hash
        end

        def new_conditional_hash
          hash = {}

          def hash.add_value( key, value )
            self[key] = value unless value.nil?
          end

          return hash
        end
      end

      module ClassMethods
        def from_connector( connector )
          Vz::SampleConfiguration.new(
            :id                   => connector.id,
            :name                 => connector.name,
            :comment              => connector.comment,
            :type                 => connector.env_config.type,
            :offline_management   => connector.env_config.offline_management,
            :net_devices          => connector.env_config.net_device,
            :qos                  => connector.env_config.qos,
            :vt                   => connector.vt_version
          )
        end
      end
    end # SampleConfiguration
  end # Adapter

  Vz::SampleConfiguration.send(:include, Adapter::SampleConfiguration)
end
