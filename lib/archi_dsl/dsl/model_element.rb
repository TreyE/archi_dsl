require "securerandom"

module ArchiDsl
  module Dsl
    class ModelElement
      attr_reader :element_id, :name

      def initialize(a_registry, e_lookup, name, **kwargs)
        @element_id = kwargs.fetch(:id, "e-" + SecureRandom.uuid)
        @element_lookup = e_lookup
        @association_registry = a_registry
        @name = name
        @element_lookup.add_element(self)
      end

      def to_xml(parent)
        element_attributes = {
          "xsi:type" => self.xsi_type,
          "identifier" => @element_id
        }
        parent["archimate"].element(element_attributes) do |r_element|
          r_element["archimate"].name(@name)
        end
      end

      def children
        []
      end

      def elements
        [self]
      end

      def view_only?
        false
      end
    end
  end
end
