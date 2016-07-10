require 'xml/libxml'
require 'breakpoint'

@root = XML::Parser.string( open(ARGV.shift).read ).parse.root

breakpoint
