module ArchiDsl
  module Dsl
    class Diagram
      attr_reader :name, :element_id

      def initialize(d_index, a_registry, lookup, name, &blk)
        @element_id = "d-" + SecureRandom.uuid
        @association_registry = a_registry
        @exclusion_registry = []
        @element_lookup = lookup
        @name = name
        @elements = []
        @groups = []
        instance_exec(&blk) if blk
      end

      def node(element_or_id)
        element = element_or_id.respond_to?(:element_id) ? element_or_id : @element_lookup.lookup(element_or_id)
        @elements << element
      end

      def to_xml(parent)
        associations = select_associations_for_diagram
        vl = ArchiDsl::Layout::ViewLayout.new(@groups, @elements, associations)
        pos = vl.positions
        view_elements = pos.select { |gp| gp.is_a?(ArchiDsl::Layout::GVNode) }
        view_assocs = pos.select { |gp| gp.is_a?(ArchiDsl::Layout::GVEdge) }
        parent[:archimate].view(
          "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
          "xsi:type" => "Diagram",
          "identifier" => @element_id) do |d_node|
          d_node[:archimate].name(@name)
          view_elements.each do |ele|
            d_node[:archimate].node(
              "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
              "xsi:type" => "Element",
              "elementRef" => ele.element,
              "identifier" => "d-#{@d_index}-" + ele.element,
              "x" => ele.x.round,
              "y" => ele.y.round,
              "w" => ele.width.round,
              "h" => ele.height.round
            )
          end
          view_assocs.each do |va|
            d_node[:archimate].connection(
              {
                "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
                "xsi:type" => "Relationship",
                "relationshipRef" => va.relationship,
                "source" => "d-#{@d_index}-" + va.source,
                "target" => "d-#{@d_index}-" + va.target,
                "identifier" => "d-#{@d_index}-" + va.relationship
              }
            )
          end
        end
      end

      protected

      def select_associations_for_diagram
        element_ids = @elements.map(&:element_id)
        group_element_ids = @groups.flat_map(&:element_ids).uniq
        all_element_ids = (element_ids + group_element_ids).uniq
        @association_registry.filter_to(all_element_ids, @exclusion_registry)
      end
    end
  end
end