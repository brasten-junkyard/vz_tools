#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

require 'vz/helper'

module Vz

  # Represents a network device.
  #
  class Interface
    include ValueObject

    attr_reader :name
    attr_reader :ip_addresses
    attr_reader :netmask
    attr_reader :nameservers
    attr_reader :gateway

    attr_reader :flags
    attr_reader :is_dhcp
    attr_reader :network_id
    attr_reader :bandwidth
    attr_reader :transfer

  end
end
