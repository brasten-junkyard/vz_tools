#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

%w(attribute_mapping marshaller schema schema_attribute
   schema_collector mapped_struct multiple_source_array
   array_association date_conversion qos_array service_locator).each do |file|
  require File.join( File.dirname(__FILE__), 'support', file )
end
