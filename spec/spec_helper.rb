# 
# spec_helper.rb
# 
# Copyright (c) 2007 Nagilum LLC.  All rights reserved.
#
# Developed by: Brasten Lee Sager
#               brasten@nagilum.com
#               Nagilum LLC
#               
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal with the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#   1. Redistributions of source code must retain the above copyright notice,
#      this list of conditions and the following disclaimers.
#   2. Redistributions in binary form must reproduce the above copyright
#      notice, this list of conditions and the following disclaimers in the
#      documentation and/or other materials provided with the distribution.
#   3. Neither the names of Brasten Lee Sager, Nagilum LLC, nor the
#      names of its contributors may be used to endorse or promote 
#      products derived from this Software without specific prior
#      written permission.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# CONTRIBUTORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# WITH THE SOFTWARE.

$LOAD_PATH.push('lib')

require 'vz'
require 'open-uri'
Dir[ File.join( File.dirname(__FILE__), 'mock', '*.rb' ) ].each do |file|
    require file
end

class String
  def begins_with?(start)
    self[0, start.length] == start
  end
  
  def ends_with?(ending)
    self[length-ending.length, ending.length] == ending
  end
end

module ProxyStub
  def build_container
    Vz::Connector::Env.new( 
      :eid => ("a".to_s * 15), 
      :parent_eid => ("b".to_s * 10), 
      :status => Vz::Connector::EnvStatus.new( :state => 6, :transition => nil )
    )
  end
end

# Helper methods and whatnot for specs
#
class SpecHelper

  class << self
    
    # Replaces some methods in the stock Node class.
    #
    def stub_node_for_tests!
      @node = Vz::Node.new
      def @node.read_exec( command )
        return read_as_lines( fixture_for(command) )        
      end

      def @node.fixture_for( command )
        case command
        when 'cat /proc/vz/veinfo'
          'veinfo'
        when 'cat /proc/bc/resources'
          'bean_counter'
        when 'vzlist -aH'
          'vzlist'
        when 'cat /proc/cpuinfo'
          'cpuinfo'
        when 'vzcpucheck -v'
          'vzcpucheck'
        when 'vzmemcheck -v -A'
          'vzmemcheck'
        when 'cat /proc/vz/vestat'
          'vestat'
        else
          if command.ends_with?('cat /proc/net/dev')
            'proc_net_dev'
          elsif command.ends_with?('.conf')
            "conf/#{command.split('/').last}"
          elsif command.begins_with?('vzcalc')
            'vzcalc'
          end
        end
      end
      
      def @node.read_as_lines( filename )
        open(File.dirname(__FILE__) + "/fixtures/#{filename}").read.split("\n")
      end

      
      Vz::Node.stub!(:new).and_return(@node)
    end
    
  end

end

