#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

require File.dirname(__FILE__) + '/base_type'
require File.join( File.dirname(__FILE__), 'perf_data' )

module Vz
  module Connector
    class ResLog < BaseType
      attr_mapping :data, :type => Vz::Connector::PerfData

    end
  end
end
