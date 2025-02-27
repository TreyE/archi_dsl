module ArchiDsl
  module View
    module ParentMethods
      def add_children_to_graph(subgraph, node_map, group_list)
        groups = @elements.select do |el|
          el.kind_of?(DiagramGroup)
        end

        groups.each do |g|
          group_list << g.element_id
        end

        containers = @elements.select do |el|
          el.kind_of?(LayoutContainer)
        end

        elems = @elements.reject do |el|
          (el.kind_of?(DiagramGroup) || el.kind_of?(LayoutContainer))
        end

        containers.each do |grp|
          prefix = grp.cluster? ? "cluster_" : ""
          sg = subgraph.add_graph("#{prefix}layoutcontainer_" + grp.element_id)
          sg.graph["label"] = ""
          apply_group_options(sg, grp.node_options)
          node_map[grp.element_id] = sg
          grp.add_children_to_graph(sg, node_map, group_list)
        end

        groups.each do |grp|
          sg = subgraph.add_graph("cluster_" + grp.element_id)
          sg["label"] = grp.name
          sg["labelloc"] = "b"
          apply_group_options(sg, grp.node_options)
          node_map[grp.element_id] = sg
          grp.add_children_to_graph(sg, node_map, group_list)
        end

        elems.each do |el|
          node_props = {}
          if el.fixed_size?
            node_props = {
              id: el.element_id,
              fixedsize: "true",
              label: el.name,
              "height" => 15.0 / 72.0,
              "width" => 15.0 / 72.0
            }
          else
            node_props = {
              id: el.element_id,
              label: el.name
            }
          end
          el_node = subgraph.add_nodes(el.element_id, **node_props)
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