module ArchiDsl
  module Dsl
    class Group
      include AssociationMethods

      attr_reader :element_id, :children, :name

      def initialize(a_registry, e_lookup, name, id, &blk)
        @association_registry = a_registry
        @name = name
        @element_id = id
        @element_lookup = e_lookup
        @children = []
        instance_exec(&blk) if blk
      end

      def elements
        @children.flat_map(&:elements) + [self]
      end

      def self.define_real_element_method(name, ele_kind)
        class_eval(<<-RUBY_CODE)
          def #{name}(element_name, element_id = "e-" + SecureRandom.uuid, &blk)
            ele = RealElement.new(@association_registry, "#{ele_kind}", element_name, element_id, &blk)
            @element_lookup.add_element(ele)
            @association_registry.add_association(self, ele, :aggregation)
            @children << ele
            ele
          end
        RUBY_CODE
      end

      ArchiDsl::Dsl::ElementMethods::REAL_ELEMENT_SET.each do |re_item|
        define_real_element_method(re_item[0], re_item[1])
      end

      def group(element_name, element_id = "g-" + SecureRandom.uuid, &blk)
        child_ele = Group.new(@association_registry, @element_lookup, element_name, id, &blk)
        @element_lookup.add_element(child_ele)
        @association_registry.add_association(self, child_ele, :aggregation)
        @children << child_ele
        child_ele
      end

      def to_xml(parent)
        element_attributes = {
          "xsi:type" => "Grouping"
        }
        element_attributes["identifier"] = @element_id
        parent["archimate"].element(element_attributes) do |r_element|
          r_element["archimate"].name(@name)
        end
      end
    end
  end
end