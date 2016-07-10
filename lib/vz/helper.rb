#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

# Requires helpers
Dir[ File.join( File.dirname(__FILE__), 'helper', '*.rb' ) ].each do |helper|
  require "vz/helper/#{helper.split(/[\/\\]/).last.split('.').first}"
end

include Vz::Helper
