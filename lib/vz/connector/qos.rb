#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

require File.dirname(__FILE__) + '/base_type'

module Vz
  module Connector
    class Qos < BaseType
      attr_mapping :id, :soft, :hard, :cur

    end
  end
end
