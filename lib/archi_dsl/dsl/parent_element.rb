module ArchiDsl
  module Dsl
    class ParentElement
      include AssociationMethods

      attr_reader :element_id, :children, :name, :folder_name

      def initialize(a_registry, e_lookup, name, **kwargs, &blk)
        @element_id = kwargs.fetch(:id, "e-" + SecureRandom.uuid)
        @association_registry = a_registry
        @name = name
        @element_lookup = e_lookup
        @children = []
        unless view_only?
          if kwargs.key?(:folder)
            @folder_name = base_folder + "/" + kwargs[:folder]
          else
            @folder_name = base_folder
          end
        end
        instance_exec(&blk) if blk
      end

      def self.define_model_element_method(name, ele_kind, association_kind)
        class_eval(<<-RUBY_CODE)
          def #{name}(element_name, **kwargs, &blk)
            folder = kwargs[:folder]
            ele = #{ele_kind}.new(@association_registry, @element_lookup, element_name, **kwargs, &blk)
            if folder
              @association_registry.add_association(self, ele, :#{association_kind}, folder: folder)
            else
              @association_registry.add_association(self, ele, :#{association_kind})
            end
            @children << ele
            ele
          end
        RUBY_CODE
      end

      def self.define_parent_element_method(name, ele_kind, association_kind)
        class_eval(<<-RUBY_CODE)
          def #{name}(element_name, **kwargs, &blk)
            folder = kwargs[:folder]
            ele = #{ele_kind}.new(@association_registry, @element_lookup, element_name, **kwargs, &blk)
            @element_lookup.add_element(ele)
            if folder
              @association_registry.add_association(self, ele, :#{association_kind}, folder: folder)
            else
              @association_registry.add_association(self, ele, :#{association_kind})
            end
            @children << ele
            ele
          end
        RUBY_CODE
      end

      def elements
        @children.flat_map(&:elements) + [self]
      end

      def view_only?
        false
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