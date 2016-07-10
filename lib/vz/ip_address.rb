#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

require 'vz/helper'

module Vz
  class IpAddress
    include Vz::Helper::ActiveVz

    attr_remote :ip
    attr_remote :netmask

    def to_s
      self.ip
    end

  end
end
