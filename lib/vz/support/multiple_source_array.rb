#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

require 'forwardable'

module Vz
  module Support

    # Allows the caller to manipulate multiple arrays as if there were one.
    # For calls that need to affect one array only, we assume the first
    # array provided during initialization is the default.
    #
    # The usefulness of this class lies in it's ability to rejoin collections
    # that must remain separate in your model for various reasons, but are
    # easier for the user to interact with as a whole.
    #
    # An container's IP addresses, for example, must physically exist under
    # the container's NetDevices collection.  But for the purposes of listing
    # and modifying an container's addresses, a single collection is prefered.
    #
    class MultipleSourceArray
      extend Forwardable

      def_delegators :combined_sources,   :[], :at, :collect, :map, :compact,
                                          :each, :each_index, :empty?, :first,
                                          :include?, :member?, :index, :join,
                                          :last, :length, :size
      def_delegators :applicable_source,  :delete
      def_delegators :each_source,        :collect!, :map!, :compact!

      def initialize( sources=[[]] )
        @sources = sources
      end

      def <<(val)
        self.default_source << val
        self.combined_sources
      end

      def concat(val)
        self.concat(val)
        self.combined_sources
      end

      def default_source
        @sources.find { |s| !s.nil? }
      end

      def combined_sources
        @sources.inject([]) do |memo, obj|
          memo + obj
        end
      end

      def applicable_source
        ApplicableSourceProxy.new( @sources )
      end

      def each_source
        EachSourceProxy.new( @sources )
      end

      def to_s
        self.map { |o| o.to_s }.join(', ')
      end

      class ApplicableSourceProxy
        def initialize( sources )
          @sources = sources
        end

        def method_missing( sym, *args, &block )
          obj = args.first
          src = @sources.find { |source| source.include?(obj) }

          src.send( sym, *args, &block )
        end
      end

      class EachSourceProxy
        def initialize( sources )
          @sources = sources
        end

        def method_missing( sym, *args, &block )
          @sources.each do |source|
            source.send( sym, *args, &block )
          end
        end
      end

    end
  end
end
