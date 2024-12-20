require "graphviz"

module ArchiDsl
  module View
    GVNode = Struct.new(:element, :x, :y, :w, :h, :children, :label)
    GVEdge = Struct.new(:relationship, :source, :target, :bendpoints)

    # Get down to a set of relationships that will be rendered. This
    #    will get a bit more complicated than that if I support diagram only
    #    entities like notes, etc. But is good enough to start
    class ViewLayout
      SCALE_FACTOR = 72

      attr_reader :g
      attr_reader :width
      attr_reader :height
      attr_reader :elements
      attr_reader :relationships
      attr_reader :groups

      def initialize(elements, relationships, element_ids, element_links, comment_links)
        @g = nil
        @relationships = relationships
        @elements = elements
        @element_ids = element_ids
        @element_links = element_links
        @comment_links = comment_links
      end

      def positions
        t_file = Tempfile.new('archidsl_graphviz')
        begin
          build_graphviz_model
          gv_output = g.output(dot: String)
          # raise gv_output
          t_file.write(gv_output)
          t_file.flush
          t_file.rewind
          model = DotInterpreter.parse(t_file.path)
          # raise model.inspect
          parse_gv_model(model)
        ensure
          t_file.unlink
        end
      end

      def debug
        build_graphviz_model
        g.output(none: String)
      end

      def preview(file_path)
        build_graphviz_model
        g.output(png: file_path)
      end

      private

      def parse_gv_model(model)
        if @height.nil? && @width.nil?
          bb = model.graph["bb"]
          _llx, _lly, @width, @height = bb.to_ruby
        end
        graph_nodes = []
        normal_nodes = []

        model.each_graph do |name, gs|
          bb = gs.graph["bb"]
          llx, lly, urx, ury = bb.to_ruby
          y = @height - ury
          h = ury - lly
          x = llx
          w = urx - llx
          children = parse_gv_model(gs)
          if name =~ /\Acluster_layoutcontainer_/ || name =~ /\Alayoutcontainer_/
            children.each do |c|
              graph_nodes << c
            end
          else
            graph_nodes << GVNode.new(name.gsub(/\Acluster_/, "").gsub("_", "-"), x, y, w, h, children)
          end
        end

        model.each_node do |n_name, n|
          # next if n.kind_of?(GraphViz)
          pos = n[:pos]
          next unless pos
          w = n[:width].to_ruby
          h = n[:height].to_ruby
          x, y = n[:pos].point
          lbl = n["label"].nil? ? nil : eval(n["label"].to_s)
          normal_nodes << GVNode.new(n.id, x - (w * SCALE_FACTOR/2), @height - y - (h * SCALE_FACTOR/2), w * SCALE_FACTOR, h * SCALE_FACTOR, [], lbl)
        end

        graph_nodes + normal_nodes
      end

      def scalef(v)
        v.to_f * SCALE_FACTOR
      end

      def scalefy(y)
        @height - scalef(y)
      end

      def build_graphviz_model
        @g = GraphViz.new( :G, :type => :digraph )
        g.graph["compound"] = true
        #g["layout"] = "fdp"
        # g.node["fixedsize"] = "true"
        # g.node["width"] = 1.0
        # g.node["height"] = 0.5
        g["fontname"] = "Lucida Grande"
        g["fontsize"] = "12pt"
        g.node["shape"] = "box"
        g.edge["dir"] = "none"
        g.edge["headclip"] = "false"
        g.edge["tailclip"] = "false"
        # g["splines"] = "ortho"
        g["rankdir"] = "BT"
        # g["dpi"] = SCALE_FACTOR
        g.node["margin"] = "0.36,0.055"

        @node_map = {}

        groups = elements.select do |el|
          el.kind_of?(DiagramGroup)
        end

        containers = elements.select do |el|
          el.kind_of?(LayoutContainer)
        end

        elems = elements.reject do |el|
          (el.kind_of?(DiagramGroup) || el.kind_of?(LayoutContainer))
        end

        containers.each do |grp|
          prefix = grp.cluster? ? "cluster_" : ""
          sg = g.add_graph("#{prefix}layoutcontainer_" + grp.element_id)
          sg["label"] = ''
          apply_group_options(sg, grp.node_options)
          @node_map[grp.element_id] = sg
          grp.add_children_to_graph(sg, @node_map)
        end

        groups.each do |grp|
          prefix = grp.cluster? ? "cluster_" : ""
          sg = g.add_graph(prefix + grp.element_id)
          sg["label"] = grp.name
          sg["labelloc"] = "b"
          apply_group_options(sg, grp.node_options)
          @node_map[grp.element_id] = sg
          grp.add_children_to_graph(sg, @node_map)
        end

        elems.each do |el|
          node_props = { }
          if el.fixed_size?
            node_props = {
              id: el.element_id,
              fixedsize: "true",
              label: el.name,
              "height" => 15.0 / SCALE_FACTOR,
              "width" => 15.0 / SCALE_FACTOR
            }
          else
            node_props = {
              id: el.element_id,
              label: el.name
            }
          end
          el_node = g.add_nodes(el.element_id, **node_props)
          el.apply_options(el_node)
          @node_map[el.element_id] = el_node
        end

        @relationships.each do |rel|
          begin
            if rel.label
              g.add_edges(@node_map[rel.to.element_id], @node_map[rel.from.element_id], label: rel.label)
            else
              g.add_edges(@node_map[rel.to.element_id], @node_map[rel.from.element_id])
            end
          rescue
            raise [rel.to.element_id, rel.from.element_id].inspect
          end
        end

        @element_links.each do |e_link|
          from, to, args = e_link
          g.add_edges(@node_map[to.element_id], @node_map[from.element_id], args)
        end

        @comment_links.each do |c_link|
          from, to, args = c_link
          g.add_edges(@node_map[to.element_id], @node_map[from.element_id], args)
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

      def element_by_id(id)
        id = id.tr('"', '')
        @elements.find { |el| el.element_id == id }
      end

      def relationship_by_id(id)
        id = id.tr('"', '')
        @relationships.find { |rel| rel.element_id == id }
      end
    end
  end
end