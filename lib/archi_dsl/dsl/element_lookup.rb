module ArchiDsl
  module Dsl
    class ElementLookup
      def initialize
        @elements = {}
      end

      def lookup(element_id)
        @elements[element_id]
      end

      def add_element(element)
        @elements[element.element_id] = element
      end
    end
  end
end