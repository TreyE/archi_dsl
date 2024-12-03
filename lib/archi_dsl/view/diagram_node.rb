module ArchiDsl
  module View
    class DiagramNode
      def initialize(element, **kwargs)
        @element = element
        @opts = kwargs
      end

      def name
        @element.name
      end

      def element_id
        @element.element_id
      end

      def element_ids
        [@element.element_id]
      end

      def apply_options(node)
        @opts.each_pair do |k, v|
          node[k] = v
        end
      end
    end
  end
end