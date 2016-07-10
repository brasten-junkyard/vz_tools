#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

require 'vztools'
require File.dirname(__FILE__) + '/../spec/spec_helper'

module VZTools
  module Adapter
    class Util
      def self.read_exec( command )
        SpecHelper.read_file('/bin/vzlist')
      end
    end
  end
end


puts VZTools::Api::Container.find_by_veid( 120 ).inspect
