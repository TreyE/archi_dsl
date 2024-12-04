module ArchiDsl
  module View
    class DiagramGroup
      include ParentMethods

      attr_reader :element_id, :name, :elements, :node_options

      def initialize(element_lookup, excl_registry, group_element, **kwargs)
        @element_lookup = element_lookup
        @group_element = group_element
        @element_id = group_element.element_id
        @exclusion_registry = excl_registry
        @name = group_element.name
        @node_options = kwargs
        @elements = []
      end

      def element_ids
        (@elements.flat_map(&:element_ids) + [@element_id]).compact.uniq
      end

      def node(element_or_id, **kwargs)
        element = element_or_id.respond_to?(:element_id) ? element_or_id : @element_lookup.lookup(element_or_id)
        @exclusion_registry << [@group_element, element, :_]
        @elements << DiagramNode.new(element, **kwargs)
      end

      def group(element_or_id, **kwargs, &blk)
        element = element_or_id.respond_to?(:element_id) ? element_or_id : @element_lookup.lookup(element_or_id)
        dg_ele = DiagramGroup.new(@element_lookup, @exclusion_registry, element, **kwargs)
        @exclusion_registry << [@group_element, element, :_]
        @elements << dg_ele
        dg_ele.instance_exec(&blk) if blk
        dg_ele.element_ids.each do |e_id|
          if dg_ele.element_id != e_id
            @exclusion_registry << [element, @element_lookup.lookup(e_id), :_]
          end
        end
      end

      def layout_container(&blk)
        dg_ele = LayoutContainer.new(@element_lookup, @exclusion_registry)
        @elements << dg_ele
        dg_ele.instance_exec(&blk) if blk
        dg_ele
      end
    end
  end
end