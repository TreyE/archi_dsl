module ArchiDsl
  module View
    class Diagram
      attr_reader :name, :element_id, :folder_name

      def initialize(d_index, a_registry, lookup, name, &blk)
        @element_id = "d-" + SecureRandom.uuid
        @association_registry = a_registry
        @exclusion_registry = []
        @element_lookup = lookup
        @name = name
        @elements = []
        @d_index = d_index
        @layout_links = []
        @folder_name = ArchiDsl::Organizations::VIEWS_BASE
        instance_exec(&blk) if blk
      end

      def node(element_or_id, **kwargs)
        element = element_or_id.respond_to?(:element_id) ? element_or_id : @element_lookup.lookup(element_or_id)
        @elements << DiagramNode.new(element, **kwargs)
      end

      def group(element_or_id, **kwargs, &blk)
        element = element_or_id.respond_to?(:element_id) ? element_or_id : @element_lookup.lookup(element_or_id)
        dg_ele = DiagramGroup.new(@element_lookup, @exclusion_registry, element, **kwargs)
        @elements << dg_ele
        dg_ele.instance_exec(&blk) if blk
        dg_ele.element_ids.each do |e_id|
          if dg_ele.element_id != e_id
            @exclusion_registry << [element, @element_lookup.lookup(e_id), :_]
          end
        end
      end

      def layout_container(**kwargs, &blk)
        dg_ele = LayoutContainer.new(@element_lookup, @exclusion_registry, **kwargs)
        @elements << dg_ele
        dg_ele.instance_exec(&blk) if blk
        dg_ele
      end

      def write_node_children(p_node, children)
        children.each do |ele|
          next unless @filtered_element_ids.include?(ele.element)
          p_node[:archimate].node(
            "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
            "xsi:type" => "Element",
            "elementRef" => ele.element,
            "identifier" => "d-#{@d_index}-" + ele.element,
            "x" => ele.x.round,
            "y" => ele.y.round,
            "w" => ele.w.round,
            "h" => ele.h.round
          ) do |new_p_node|
            write_node_children(new_p_node, ele.children)
          end
        end
      end

      def layout_link(from, to, **kwargs)
        from_element = from.respond_to?(:element_id) ? from : @element_lookup.lookup(from)
        to_element = to.respond_to?(:element_id) ? to : @element_lookup.lookup(to)
        @layout_links << [from_element, to_element, kwargs]
      end

      def debug
        associations = select_associations_for_diagram
        @filtered_element_ids = all_element_ids
        vl = ArchiDsl::View::ViewLayout.new(@elements, associations, all_element_ids, @layout_links)
        vl.debug
      end

      def preview(file_path)
        associations = select_associations_for_diagram
        @filtered_element_ids = all_element_ids
        vl = ArchiDsl::View::ViewLayout.new(@elements, associations, all_element_ids, @layout_links)
        vl.preview(file_path)
      end

      def to_xml(parent)
        associations = select_associations_for_diagram
        @filtered_element_ids = all_element_ids
        vl = ArchiDsl::View::ViewLayout.new(@elements, associations, all_element_ids, @layout_links)
        view_elements = vl.positions
        parent[:archimate].view(
          "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
          "xsi:type" => "Diagram",
          "identifier" => @element_id) do |d_node|
          d_node[:archimate].name(@name)
          view_elements.each do |ele|
            next unless @filtered_element_ids.include?(ele.element)
            d_node[:archimate].node(
              "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
              "xsi:type" => "Element",
              "elementRef" => ele.element,
              "identifier" => "d-#{@d_index}-" + ele.element,
              "x" => ele.x.round,
              "y" => ele.y.round,
              "w" => ele.w.round,
              "h" => ele.h.round
            ) do |p_node|
              write_node_children(p_node, ele.children)
            end
          end
          associations.each do |va|
            d_node[:archimate].connection(
              {
                "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
                "xsi:type" => "Relationship",
                "relationshipRef" => va.element_id,
                "source" => "d-#{@d_index}-" + va.from.element_id,
                "target" => "d-#{@d_index}-" + va.to.element_id,
                "identifier" => "d-#{@d_index}-" + va.element_id
              }
            )
          end
        end
      end

      protected

      def all_element_ids
        @elements.flat_map(&:element_ids).uniq
      end

      def select_associations_for_diagram
        @association_registry.filter_to(all_element_ids, @exclusion_registry)
      end
    end
  end
end