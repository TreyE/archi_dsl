module ArchiDsl
  module Dsl
    class TechnologyProcess < ParentElement
      def base_folder
        Organizations::TECHNOLOGY_BASE
      end

      def xsi_type
        "TechnologyProcess"
      end

      def self.child_association_kind
        :assignment
      end

      ArchiDsl::Dsl::ElementMethods::MODEL_ELEMENT_SET.each do |re_item|
        define_model_element_method(re_item[0], re_item[1], self.child_association_kind)
      end

      ArchiDsl::Dsl::ElementMethods::PARENTING_ELEMENT_SETS.each do |re_item|
        define_parent_element_method(re_item[0], re_item[1], self.child_association_kind)
      end
    end
  end
end