#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

require 'forwardable'

module Vz
  module Helper

    # Wrapper for Forwardable that provides methods and usages that I
    # find preferable to Forwardable's def_delegators.
    #
    # Similar to ActionPack's #delegate method but with better
    # functionality and more concise syntax.
    #
    module DelegationHelper

      class << self
        def included(base)
          base.extend(::Forwardable)
          base.extend(ClassMethods)
        end
      end

      # Aliased methods
      #
      module ClassMethods

        # Defines delegation methods for *methods on accessor.
        #
        # Usages:
        #
        #   # These two examples are functionally identical.
        #   #
        #   delegate :first_name, :last_name => :order
        #   delegate [ :first_name, :last_name ] => :order
        #
        #   # Generates #order_first_name and #order_last_name as
        #   # delegates.
        #   #
        #   delegate :first_name, :last_name => :order, :with_prefix => true
        #
        #   # Or, come up with a more appropriate prefix.
        #   #
        #   # This example produces #customer_first_name and #customer_last_name
        #   # methods, which would be preferable in some situations to the
        #   # default #user_account_first_name methods -- for example, on an
        #   # Order object where "customer" is understandable, but "user_account"
        #   # is out-of-context.
        #   #
        #   delegate :first_name, :last_name => :user_account, :with_prefix => :customer
        #
        def delegate(*args)
          hash          = args.pop
          with_prefix   = hash.delete(:with_prefix)
          target        = hash.values.first
          methods       = ( [ hash.keys ] << args ).flatten.compact

          with_prefix = target.to_s[0..-1] if target.to_s[-1] == '_'
          with_prefix = target if ( with_prefix == true )

          delegate_with_prefix( target, with_prefix, *methods )
        end

        private

          # The guts of #delegate, extracted for readability and future
          # extensibility reasons.
          #
          def delegate_with_prefix(attribute, prefix, *methods)
            methods.each do |method|
              method_name = ( prefix ? "#{prefix.to_s}_#{method.to_s}" : method.to_s ).to_sym
              def_delegator( attribute.to_sym, method.to_sym, method_name )
            end
          end

      end


    end
  end
end
