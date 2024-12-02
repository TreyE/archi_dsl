module ArchiDsl
  module Organizations
    class Folder
      attr_reader :label

      def initialize(label)
        @label = label
        @children = Hash.new do |h, k|
          h[k] = Folder.new(k)
        end
        @elements = []
      end

      def [](label)
        @children[label]
      end

      def add_element(element)
        @elements << element
      end

      def to_xml(parent_node)
        parent_node[:archimate].item do |i_node|
          i_node[:archimate].label(@label)

          @children.values.sort_by(&:label).each do |c|
            c.to_xml(i_node)
          end

          @elements.each do |ele|
            i_node[:archimate].item({identifierRef: ele.element_id})
          end
        end
      end
    end
  end
end