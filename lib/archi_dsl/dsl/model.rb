module ArchiDsl
  module Dsl
    class Model
      include ArchiDsl::Dsl::ElementMethods
      include ArchiDsl::Dsl::AssociationMethods

      def initialize(name, id, &blk)
        @children = []
        @identifier = id
        @name = name
        @element_lookup = ElementLookup.new
        @association_registry = AssociationRegistry.new(@element_lookup)
        @diagrams = []
        @d_index = 0
        instance_exec(&blk) if blk
      end

      def diagram(name, &blk)
        dia = ArchiDsl::View::Diagram.new(@d_index, @association_registry, @element_lookup, name, &blk)
        @diagrams << dia
        @d_index = @d_index + 1
        dia
      end

      def preview_diagram(diagram_name, file_path)
        diagram = @diagrams.detect { |d| d.name == diagram_name }
        diagram.preview(file_path)
      end

      def to_xml
        elements = @children.flat_map(&:elements)
        Nokogiri::XML::Builder.new do |xml|
          xml["archimate"].model(
            {
              "xmlns" => "http://www.opengroup.org/xsd/archimate/3.0/",
              "xmlns:archimate" => "http://www.opengroup.org/xsd/archimate/3.0/",
              "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
              "identifier" => @identifier
            }
          ) do |model|
            model["archimate"].name(@name)

            model["archimate"].elements do |elements_node|
              elements.each do |element|
                element.to_xml(elements_node)
              end
            end

            if @association_registry.associations.any?
              model["archimate"].relationships do |assoc_node|
                @association_registry.associations.each do |assoc|
                  assoc.to_xml(assoc_node)
                end
              end
            end

            viewable_elements = elements.reject(&:view_only?)

            if viewable_elements.any?
              grouped_views = viewable_elements.group_by(&:base_folder)

              model["archimate"].organizations do |org_node|
                grouped_views.each_pair do |k, v|
                  org_node["archimate"].item do |i_node|
                    i_node["archimate"].label(k)
                    v.each do |f_ele|
                      i_node["archimate"].item({identifierRef: f_ele.element_id})
                    end
                  end
                end

                if @association_registry.associations.any?
                  org_node["archimate"].item do |a_item_node|
                    a_item_node["archimate"].label(Organizations::RELATIONS_BASE)
                    @association_registry.associations.each do |assoc|
                      a_item_node["archimate"].item({identifierRef: assoc.id})
                    end
                  end
                end
              end
            end

            if @diagrams.any?
              model["archimate"].views do |v_node|
                v_node["archimate"].diagrams do |v_node|
                  @diagrams.each do |d|
                    d.to_xml(v_node)
                  end
                end
              end
            end
          end
        end.to_xml
      end
    end
  end
end
