require "securerandom"

module ArchiDsl
  module Dsl
    class RealElement < ElementBase
      def initialize(a_registry, tag, name, **kwargs, &blk)
        @element_id = kwargs.fetch(:id, "e-" + SecureRandom.uuid)
        @association_registry = a_registry
        @tag = tag
        @name = name
        @children = []
        instance_exec(&blk) if blk
      end

      def to_xml(parent)
        element_attributes = {
          "xsi:type" => @tag,
          "identifier" => @element_id
        }
        parent["archimate"].element(element_attributes) do |r_element|
          r_element["archimate"].name(@name)
        end
      end

      def view_only?
        true
      end
    end
  end
end
