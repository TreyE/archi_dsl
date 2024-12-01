module ArchiDsl
  module Dsl
    class Group < ParentElement
      def view_only?
        true
      end

      def xsi_type
        "Grouping"
      end

      def self.child_association_kind
        :aggregation
      end

      ArchiDsl::Dsl::ElementMethods::MODEL_ELEMENT_SET.each do |re_item|
        define_model_element_method(re_item[0], re_item[1], self.child_association_kind)
      end

      ArchiDsl::Dsl::ElementMethods::REAL_ELEMENT_SET.each do |re_item|
        define_real_element_method(re_item[0], re_item[1], self.child_association_kind)
      end

      ArchiDsl::Dsl::ElementMethods::PARENTING_ELEMENT_SETS.each do |re_item|
        define_parent_element_method(re_item[0], re_item[1], self.child_association_kind)
      end
    end
  end
end