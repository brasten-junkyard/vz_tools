#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

require 'forwardable'
require 'xml/libxml'

require File.dirname(__FILE__) + '/mapped_struct'

module Vz
  module Support
    class Marshaller
      extend Forwardable

      @@registered_types = {}

      def_delegator Vz, :logger, :log

      class << self
        extend Forwardable

        def_delegator Vz, :logger, :log
        def_delegators :new, :marshal, :unmarshal

        # Adds a class to the global registry, used while unmarshalling
        # XML to objects
        #
        # Arguments:
        #   --> ( name, class ) to register a class to a specific name
        #
        #   --> ( class ) to register a class to a name derived from the class name
        #
        def register_type( *args )
          klass     = args.pop
          name      = args.pop || type_name_for( klass )

          log.debug("( Type Classes ) Registering Type:  #{name.to_s} --> #{klass}")
          ( @@registered_types ||= {} )[name.to_s] = klass
        end

        def unregister_type( name_or_class )
          name = type_name_for( name_or_class )

          ( @@registered_types ||= {} ).delete(name.to_s)
        end

        # Remove all currently-registered types
        #
        def clear_registered_types!
          log.debug("( Type Classes ) Clearing Registered Types!")
          log.debug("   --> Because: #{caller.join("\n")}")
          @@registered_types = {}
        end

        def type_name_for( name_or_class )
          return name_or_class.to_s if (name_or_class.is_a?(String) || name_or_class.is_a?(Symbol))

          name_or_class.name.split('::').last.snakecase
        end
      end


      def marshal( obj, options={} )
        xml =
          if options[:builder]
            options.delete(:builder)
          else
            builder = Builder::XmlMarkup.new(:indent => 2)
            builder.instruct!
            builder
          end

        xml.tag!( obj.local_name, (obj.root_attributes(options) || {}) ) do
          obj.marshal_attributes( xml, options ) if obj.respond_to?(:marshal_attributes)
        end

        xml.target!
      end



      def unmarshal( xml, options={} )
#        puts("Unmarshal: #{xml.inspect}")
        log.debug("Unmarshal: #{xml}")

        xml       = ( (xml.kind_of?(XML::Node) || xml.kind_of?(XML::Attr)) ? xml : XML::Parser.string( xml ).parse.root )
        return nil if xml.nil?

        klass     = options[:class] || get_value_class( xml )
        return nil if klass.nil?

        log.debug("Class is --> #{klass.inspect}")

        object = klass.new
        if ( !klass.respond_to?(:schema) || klass.schema.nil? )
          unmarshal_without_schema( object, xml )
        else
          unmarshal_with_schema( object, klass.schema, xml )
        end

        return object
      end

      private

        def unmarshal_without_schema( obj, element )
          log.debug("Unmarshal Without Schema: #{element}")

          return nil if element.nil?

          strip_whitespace(element).each do |elem|

            value_object = typecast_element( elem, SchemaAttribute.new( nil, :type => :auto ) )

            if !(current = obj.send(elem.name.to_sym)).nil?
              current = obj.send(elem.name.to_sym)

              log.debug("-------- Element Name: #{elem.name.to_s} --------")
              log.debug("-------- Text        : #{elem.text?} --------")
              log.debug("   current == #{current.inspect}")
              obj.send("#{elem.name}=".to_sym, Array.new( [current] )) unless current.kind_of?(Array)
              log.debug("   new == #{obj.send(elem.name.to_sym).inspect}")


              obj.send(elem.name.to_sym) << value_object
            else
              obj.send("#{elem.name}=".to_sym, value_object)
            end

          end
        end

        def unmarshal_with_schema( obj, schema, element )
          log.debug("Unmarshal With Schema: #{element}")

          return nil if element.nil?

          schema.attributes.each_pair do |attr_name, attr_descriptor|
#            puts "Unmarshal_With_Schema:: element is #{element.to_s}"
#            puts "Unmarshal_With_Schema:: xpath #{attr_descriptor.xpath}"

            elements = strip_whitespace(element.find( attr_descriptor.xpath ))

#            puts "Unmarshal_With_Schema:: elements       == #{elements.to_s}"
#            puts "Unmarshal_With_Schema:: elements.class == #{elements.class}" if elements.respond_to?(:first)

            value_object =
              if attr_descriptor.array?
                elements.map { |node| typecast_element(node, attr_descriptor) }.compact
              elsif elements.kind_of?(String)
                elements
              else
                typecast_element( (elements.respond_to?(:first) ? elements.first : elements), attr_descriptor)
              end

            value_object = filter( obj, attr_descriptor.filter, value_object ) if attr_descriptor.filter

            obj.send("#{attr_name.to_s}=".to_sym, value_object)
          end
        end

        def typecast_element( element, attr_descriptor )
          return nil if element.nil?

          log.debug("Typecast Element      : #{element.inspect}")
          log.debug("  --> AttrDescriptor  : #{attr_descriptor.inspect}")

          value_object = nil

          if attr_descriptor.schema
            # If we have a schema, then we know this element is going to be an object
            # of some kind with custom mappings.

            value_object = ( attr_descriptor.element_type == :auto ? get_value_class( element ) : attr_descriptor.element_type ).new
            unmarshal_with_schema( value_object, attr_descriptor.schema, element )
          else
            # No schema, so it could be a simple value OR a complex object

            log.debug("  --> Element      : #{element.class.name}")
            log.debug("  --> AttrDesc Type: #{attr_descriptor.element_type.inspect}")
            log.debug("  --> children?    : #{element.children?}") if element.respond_to?(:children)

            if (attr_descriptor.element_type == :string ||
                 (attr_descriptor.element_type == :auto   &&
                 (element.is_a?(String) ||
                   element.is_a?(XML::Attr) ||
                   (element.is_a?(XML::Node) && (element.find('./*').length == 0)))))

              value_object = get_single_value_from( element )
            elsif ( attr_descriptor.element_type == :integer )
              value_object = get_single_value_from( element ).to_i
            elsif ( attr_descriptor.element_type == :float )
              value_object = get_single_value_from( element ).to_f
            else
              value_object =
                if attr_descriptor.element_type == :auto
                  unmarshal( element )
                else
                  unmarshal( element, :class => attr_descriptor.element_type )
                end
            end
          end

          log.debug("  -------> ValueObject: #{value_object.inspect}")

          return value_object
        end

        # Get a registered class for this node name, OR an OpenStruct
        #
        def get_value_class( element )
          klass = @@registered_types[element.name.to_s]

          # Try by type attribute if element name doesn't work
          if ( klass.nil? && (type_attr = element.find_first('./@*[local-name()="type"]')) )
            klassname   = type_attr.value.split(":").last[0..-5]
            log.debug("  --> Trying by type: #{klassname}")
            klass       = @@registered_types[ klassname.to_s ]
          end

          # Decision Tree --> Result returns from method
          result =
            if klass.nil?
              MappedStruct
            elsif klass.respond_to?(:get_class_for_element)
              klass.get_class_for_element(element)
            else
              klass
            end

          log.debug("GetValueClass for #{element.inspect} --> #{result}")

          result
        end

        # Get a string value from this node using a best-guess as to
        # what data we want based on the node type
        #
        def get_single_value_from( node )
          node = node.first if node.is_a?(Array)

          log.debug(" --: GetSingleValueFrom: #{node.class}")

          return nil if node.nil?

          case node
          when String
            node
          when XML::Attr
            node.value.to_s
          when XML::Node
            node.find_first('./text()').to_s
          end
        end

        # Apply a filter to a value_object
        #
        def filter( obj, filter, value )
          log.debug("Applying Filter: #{obj}.#{filter.to_s}( #{value} )")

          case filter
          when Symbol
            obj.send( filter, value )
          when Proc
            filter.call(value)
          end
        end

        def strip_whitespace( elements )
          elements.find_all { |elem| !elem.kind_of?(XML::Node) || !( elem.name == "text" && !elem.children? ) }
        end

    end
  end
end
