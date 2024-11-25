module ArchiDsl
  module Dsl
    class ElementBase
      attr_reader :element_id, :name

      def children
        []
      end

      def elements
        [self]
      end
    end
  end
end