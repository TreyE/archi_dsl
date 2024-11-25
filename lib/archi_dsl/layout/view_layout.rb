require "graphviz"

module ArchiDsl
  module Layout
    GVNode = Struct.new(:element, :x, :y, :width, :height)
    GVEdge = Struct.new(:relationship, :source, :target, :bendpoints)
    # Get down to a set of relationships that will be rendered. This
    #    will get a bit more complicated than that if I support diagram only
    #    entities like notes, etc. But is good enough to start
    class ViewLayout
      SCALE_FACTOR = 110

      attr_reader :g
      attr_reader :width
      attr_reader :height
      attr_reader :elements
      attr_reader :relationships
      attr_reader :groups

      def initialize(groups, elements, relationships)
        @g = nil
        @groups = groups
        @relationships = relationships
        @elements = elements
      end

      def positions
        build_graphviz_model
        gv_output = g.output(plain: String)
        parse_plain_graphviz(gv_output)
      end

      private

      def scalef(v)
        v.to_f * SCALE_FACTOR
      end

      def scalefy(y)
        @height - scalef(y)
      end

      # graph scale width height
      def plain_graph(cols)
        @scale, @width, @height = cols.map(&:to_f)
        @width = scalef(@width)
        @height = scalef(@height)
        nil
      end

      # node name x y width height label style shape color fillcolor
      def plain_gv_node(cols)
        id, x, y, width, height = cols
        GVNode.new(id.tr('"', ''), scalef(x), scalefy(y), scalef(width), scalef(height))
      end

      def plain_gv_edge(cols)
        # edge tail head n x1 y1 .. xn yn [label xl yl] style color
        target_id, source_id, point_count = cols
        point_count = point_count.to_i
        points = cols.slice(3, 2 * point_count)
        id = cols[3 + (2 * point_count)]
        GVEdge.new(
          id.tr('"', ''),
          source_id.tr('"', ''),
          target_id.tr('"', ''),
          make_bendpoints(points.map(&:to_f))
        )
      end

      # The points we get from graphviz are a set of bspline control points
      # So theory: we could take 1st point and every 3rd pt after
      def make_bendpoints(points)
        all_points = []
        points.each_slice(2) { |xy| all_points << xy }
        bps = []
        all_points.each_slice(3) { |ctrl| bps << ctrl[0] }
        bps.reverse.map do |xy|
          [ 
            scalef(xy[0]) + 55,
            scalefy(xy[1]) + 37.5
          ]
        end
      end

      def parse_plain_line(line)
        cols = line.split
        case cols.shift
        when "graph"
          plain_graph(cols)
        when "node"
          plain_gv_node(cols)
        when "edge"
          plain_gv_edge(cols)
        end
      end

      def parse_plain_graphviz(str)
        str.each_line.map { |line| parse_plain_line(line) }.compact
      end

      def build_graphviz_model
        @g = GraphViz.new( :G, :type => :digraph )
        g["compound"] = true
        g.node["fixedsize"] = "true"
        g.node["width"] = 1.0
        g.node["height"] = 0.5
        g.node["shape"] = "box"
        g.edge["dir"] = "none"
        g.edge["headclip"] = "false"
        g.edge["tailclip"] = "false"
        g["splines"] = "ortho"
        g["rankdir"] = "TB"
        g["dpi"] = 110.0

        node_map = {}

        # TODO: generate unique view element ids
        elements.each do |el|
          node_map[el.element_id] = g.add_nodes(el.element_id, id: el.element_id, label: el.name)
        end

        @relationships.each do |rel|
          begin
            g.add_edges(node_map[rel.to.element_id], node_map[rel.from.element_id], label: rel.id)
          rescue
            raise [rel.to.element_id, rel.from.element_id].inspect
          end
        end
      end

      def element_by_id(id)
        id = id.tr('"', '')
        @elements.find { |el| el.element_id == id }
      end

      def relationship_by_id(id)
        id = id.tr('"', '')
        @relationships.find { |rel| rel.id == id }
      end
    end
  end
end