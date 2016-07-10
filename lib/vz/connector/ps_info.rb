#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

require 'base64'

module Vz
  module Connector
    class PsInfo < BaseType

      attr_mapping :process, :array => true do
        attr_mapping :pid, :type  => :integer
        attr_mapping :param, :array => true,
                     :filter => Proc.new { |p| p.map { |v| Base64.decode64(v) } }
      end
      attr_mapping :param_id, :array => true

      # Marshal up the attributes
      #
      def marshal_attributes( xml, options={} )
        self.process.each do |proc|
          xml.process do
            xml.pid( proc.pid )
            self.param.each do |par| xml.param( par )
                xml.param( encode64(par) )
            end
          end
          xml.process( encode64(self.proc) )
        end
        xml.param_id( self.param_id )
      end

    end
  end
end
