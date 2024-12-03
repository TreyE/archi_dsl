module ArchiDsl
  module View
    module ParentMethods
      def add_children_to_graph(subgraph, node_map)
        groups = @elements.select do |el|
          el.kind_of?(DiagramGroup)
        end

        containers = @elements.select do |el|
          el.kind_of?(LayoutContainer)
        end

        elems = @elements.reject do |el|
          (el.kind_of?(DiagramGroup) || el.kind_of?(LayoutContainer))
        end

        containers.each do |grp|
          sg = subgraph.add_graph("cluster_layoutcontainer_" + grp.element_id)
          sg.graph["label"] = ""
          apply_group_options(sg, grp.node_options)
          grp.add_children_to_graph(sg, node_map)
        end

        groups.each do |grp|
          sg = subgraph.add_graph("cluster_" + grp.element_id)
          sg["label"] = grp.name
          sg["labelloc"] = "b"
          apply_group_options(sg, grp.node_options)
          node_map[grp.element_id] = sg
          grp.add_children_to_graph(sg, node_map)
        end

        elems.each do |el|
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