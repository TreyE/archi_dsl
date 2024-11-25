module ArchiDsl
  module Dsl
    class DiagramGroup
      attr_reader :element_id, :name, :elements

      def initialize(element_lookup, excl_registry, group_element)
        @element_lookup = element_lookup
        @group_element = group_element
        @element_id = group_element.element_id
        @exclusion_registry = excl_registry
        @name = group_element.name
        @groups = []
        @elements = []
      end

      def element_ids
        element_ids = @elements.map(&:element_id)
        group_element_ids = @groups.flat_map(&:element_ids).uniq
        all_element_ids = ([@element_id] + element_ids + group_element_ids).uniq
      end

      def node(element_or_id)
        element = element_or_id.respond_to?(:element_id) ? element_or_id : @element_lookup.lookup(element_or_id)
        @exclusion_registry << [self, element, :aggregation]
        @elements << element
      end

      def group(element_or_id, &blk)
        element = element_or_id.respond_to?(:element_id) ? element_or_id : @element_lookup.lookup(element_or_id)
        dg_ele = DiagramGroup.new(element_lookup, @exclusion_registry, element)
        @groups << dg_ele
        dg_ele.instance_exec(&blk)
      end
    end
  end
end