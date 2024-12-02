module ArchiDsl
  module View
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
        ([@element_id] + element_ids + group_element_ids).uniq
      end

      def node(element_or_id)
        element = element_or_id.respond_to?(:element_id) ? element_or_id : @element_lookup.lookup(element_or_id)
        @exclusion_registry << [@group_element, element, :_]
        @elements << element
      end

      def group(element_or_id, &blk)
        element = element_or_id.respond_to?(:element_id) ? element_or_id : @element_lookup.lookup(element_or_id)
        dg_ele = DiagramGroup.new(@element_lookup, @exclusion_registry, element)
        @exclusion_registry << [@group_element, element, :_]
        @groups << dg_ele
        dg_ele.instance_exec(&blk) if blk
      end

      def add_children_to_graph(subgraph, node_map)
        @groups.each do |grp|
          sg = subgraph.add_graph("cluster_" + grp.element_id)
          sg["label"] = grp.name
          sg["labelloc"] = "b"
          node_map[grp.element_id] = sg
          # sg.add_node(grp.name, label: grp.name)
          grp.add_children_to_graph(sg, node_map)
        end
        @elements.each do |el|
          node_map[el.element_id] = subgraph.add_nodes(el.element_id, id: el.element_id, label: el.name)
        end
      end
    end
  end
end