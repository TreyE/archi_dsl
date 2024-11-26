module ArchiDsl
  module Dsl
    class SystemSoftware < ParentElement
      def xsi_type
        "SystemSoftware"
      end

      def self.child_association_kind
        :assignment
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