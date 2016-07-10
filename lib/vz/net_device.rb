#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

require 'vz/helper'
require 'vz/ip_address'

module Vz
  class NetDevice
    include Vz::Helper::ActiveVz

    attr_remote :id
    attr_remote :host_routed
    attr_remote :default_gateway
    attr_remote :mac_address
    attr_remote :nameservers
    attr_remote :ip_addresses
    attr_remote :dhcp
    attr_remote :network_id

    def ip_addresses=(val)
      return @ip_addresses = val if val.nil?

      @ip_addresses =
        Vz::Support::ArrayAssociation.new(
          val.map { |v| (v.respond_to?(:to_model_hash) ? IpAddress.new( v.to_model_hash() ) : v) }
        )
    end

    def changed_attributes
      ca      = super()
      ca << :id unless ca.empty?
      ca << :host_routed if self.id == 'venet0'

      return ca
    end

  end
end
