module ArchiDsl
  module Dsl
    class ParentElement
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

      def self.define_real_element_method(name, ele_kind, association_kind)
        class_eval(<<-RUBY_CODE)
          def #{name}(element_name, element_id = "e-" + SecureRandom.uuid, &blk)
            ele = RealElement.new(@association_registry, "#{ele_kind}", element_name, element_id, &blk)
            @element_lookup.add_element(ele)
            @association_registry.add_association(self, ele, :#{association_kind})
            @children << ele
            ele
          end
        RUBY_CODE
      end

      def self.define_parent_element_method(name, ele_kind, association_kind)
        class_eval(<<-RUBY_CODE)
          def #{name}(element_name, element_id = "e-" + SecureRandom.uuid, &blk)
            ele = #{ele_kind}.new(@association_registry, @element_lookup, element_name, element_id, &blk)
            @element_lookup.add_element(ele)
            @association_registry.add_association(self, ele, :#{association_kind})
            @children << ele
            ele
          end
        RUBY_CODE
      end

      def elements
        @children.flat_map(&:elements) + [self]
      end

      def to_xml(parent)
        element_attributes = {
          "xsi:type" => xsi_type
        }
        element_attributes["identifier"] = @element_id
        parent["archimate"].element(element_attributes) do |r_element|
          r_element["archimate"].name(@name)
        end
      end
    end
  end
end