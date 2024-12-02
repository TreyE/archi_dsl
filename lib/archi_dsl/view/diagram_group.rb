module ArchiDsl
  module View
    class DiagramGroup
      attr_reader :element_id, :name, :elements, :node_options

      def initialize(element_lookup, excl_registry, group_element, **kwargs)
        @element_lookup = element_lookup
        @group_element = group_element
        @element_id = group_element.element_id
        @exclusion_registry = excl_registry
        @name = group_element.name
        @node_options = kwargs
        @groups = []
        @elements = []
      end

      def element_ids
        element_ids = @elements.map(&:element_id)
        group_element_ids = @groups.flat_map(&:element_ids).uniq
        ([@element_id] + element_ids + group_element_ids).uniq
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
        @groups << dg_ele
        dg_ele.instance_exec(&blk) if blk
      end

      def add_children_to_graph(subgraph, node_map)
        @groups.each do |grp|
          sg = subgraph.add_graph("cluster_" + grp.element_id)
          sg["label"] = grp.name
          sg["labelloc"] = "b"
          apply_group_options(sg, grp.node_options)
          node_map[grp.element_id] = sg
          grp.add_children_to_graph(sg, node_map)
        end
        @elements.each do |el|
          el_node = subgraph.add_nodes(el.element_id, id: el.element_id, label: el.name)
          el.apply_options(el_node)
          node_map[el.element_id] = el_node
        end
      end

      def apply_group_options(subgraph, opts)
        options = opts.clone
        node_options = options.delete(:node) || {}
        node_options.each_pair do |k, v|
          subgraph.node[k] = v
        end
        options.each_pair do |k, v|
          subgraph[k] = v
        end
      end
    end
  end
end