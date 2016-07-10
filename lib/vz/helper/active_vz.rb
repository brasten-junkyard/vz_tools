#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

module Vz
  module Helper

    # ActiveVZ provides support methods for objects acting as active
    # interface objects (nodes, containers, etc).
    #
    module ActiveVz

      def self.included(klass)
        klass.send(:include, Vz)
        klass.send(:attr_accessor, :document)
        klass.send(:include, InstanceMethods)
        klass.extend(ClassMethods)
      end

      module InstanceMethods
        # Initializes a new ActiveVz object.
        #
        #     evt = ActiveVzSubclass.new( :id => 1, :veid => 400, ... )
        #
        def initialize( params={} )
          @document = params.delete(:document) || reset_modified_document!
          update_attributes_and_baseline!( params )

          reset_modified_document!
        end

        def to_hash
          hash = {}
          self.remote_attributes.each do |a|
            obj = send(a.to_sym)

            hash[a.to_sym] = ( obj.respond_to?(:to_hash) ? obj.to_hash : obj )
          end

          return hash
        end

        def get_text( *args )
          element = ( args.last.kind_of?(Symbol) ? self.document : args.pop )

          element.text( build_xpath_for(args) )
        end

        def get_node( *args )
          element = ( args.last.kind_of?(Symbol) ? self.document : args.pop )

          element.get_elements( build_xpath_for(args) ).first
        end

        def get_nodes( *args )
          element = ( args.last.kind_of?(Symbol) ? self.document : args.pop )

          element.get_elements( build_xpath_for(args) )
        end

        def set_array( *args )
          arr       = args.pop
          path      = args.dup
          last      = args.pop
          elements  = args

          parent    = build_document_tree( elements )
          modified  = build_document_tree( elements, self.modified_document ) if self.modified_document

          get_nodes( path, parent ).each { |node| node.remove() }
          get_nodes( path, modified ).each { |node| node.remove() } if self.modified_document

          arr.each do |val|
            parent.add_element(last.to_s).text = val.to_s
            modified.add_element(last.to_s).text = val.to_s if self.modified_document
          end
        end

        # Sets text value of the specified node.
        #
        # Node path is represented by a multiple
        # symbols.
        #
        def set_text( *args )
          value     = args.pop
          elements  = args

          value_node    = build_document_tree( elements )
          modified_node = build_document_tree( elements, self.modified_document ) if self.modified_document

          value_node.text     = value
          modified_node.text  = value if self.modified_document
        end

        def method_missing( sym, *args, &block )
          if ( options = self.remote_attributes[sym] )
            options[:type] ||= :string
            options[:path] ||= [ sym ]

            if ( options[:type].to_sym == :array )
              get_nodes( *options[:path] )
            else
              get_text( *options[:path] )
            end
          else
            super
          end
        end

        def remote_attributes
          self.class.remote_attributes
        end

        def changed?
          !self.changed_attributes.empty?
        end

        def changed_attributes
          (self.remote_attributes).inject([]) do |memo, attribute|
            old_obj = @_object_baseline[attribute.to_sym]
            new_obj = send(attribute.to_sym)

            if ( (old_obj != new_obj) || (new_obj.respond_to?(:changed?) && new_obj.changed?) )
              memo << attribute
            end

            memo
          end
        end

        def build_xpath_for( path_descriptor )
          if path_descriptor.kind_of?(Symbol)
            pd = path_descriptor.to_s.split('/')

            (pd.length > 1) ? build_xpath_for( pd ) : "./*[local-name()='#{pd.first}']"
          elsif path_descriptor.kind_of?(Array)
            "./" + path_descriptor.map { |p| "./*[local-name()='#{p.to_s}']" }.join('/')
          else
            path_descriptor
          end
        end

        def build_document_tree( path_descriptor, doc=self.document )
          path_descriptor.inject(doc) do |parent, cur|
            parent.get_elements("./*[local-name()='#{cur.to_s}']").first || parent.add_element(cur.to_s)
          end
        end

        def modified_document
          @_modified_document
        end

        def clear_baseline!
          @_object_baseline = {}
        end

        def update_attributes_and_baseline!( hash_or_object )
          if hash_or_object.kind_of?(Hash)
            hash_or_object.each_pair do |key, value|
              method = "#{key.to_s}=".to_sym

              send( method, value ) if respond_to?( method )

              set_value = send( key.to_sym )
              ( @_object_baseline ||= {} )[key.to_sym] =
                begin
                  set_value.dup
                rescue TypeError
                  set_value
                end
            end
          else
            hash =
              self.remote_attributes.inject({}) do |memo, obj|
                memo[obj.to_sym] = hash_or_object.send(obj.to_sym) if hash_or_object.respond_to?(obj.to_sym)
                memo
              end

            update_attributes_and_baseline!( hash )
          end
        end

        def change_document!( document )
          @document = document
          reset_modified_document!
        end

        def reset_modified_document!
          @_modified_document = ( respond_to?(:generate_document) ? REXML::Document.new( generate_document() ) : REXML::Document.new("<root></root>") ).root
        end

      end

      module ClassMethods
        def attr_remote( name, options={} )
          @_remote_attributes ||= {}

          unless @_remote_attributes.keys.include?( name.to_sym )
            self.module_eval(<<-EOV, __FILE__, __LINE__)
              def #{name.to_s}
                options = self.remote_attributes[:#{name.to_s}]
                options[:type] ||= :string
                options[:path] ||= [ :#{name.to_s} ]

                if ( options[:type].to_sym == :array )
                  get_nodes( *options[:path] ).map { |n| n.text }.compact
                else
                  get_text( *options[:path] )
                end
              end

              def #{name.to_s}=(val)
                options = self.remote_attributes[:#{name.to_s}]
                options[:type] ||= :string
                options[:path] ||= [ :#{name.to_s} ]

                if ( options[:type].to_sym == :array )
                  set_array( *(options[:path] + [val]) )
                else
                  set_text( *(options[:path] + [val]) )
                end
              end
            EOV

            @_remote_attributes[name.to_sym] = options
          end
        end

        def remote_attributes
          @_remote_attributes ||= {}
        end

        def inherited(subclass)
          subclass.instance_variable_set(:@_remote_attributes, @_remote_attributes.dup) unless @_remote_attributes.nil?
        end
      end

    end
  end
end
