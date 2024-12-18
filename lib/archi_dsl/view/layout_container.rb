module ArchiDsl
  module View
    class LayoutContainer
      attr_reader :elements, :element_id, :node_options

      include ParentMethods

      def initialize(element_lookup, excl_registry, **kwargs)
        opts = kwargs.dup
        is_cluster_opt = opts.delete(:cluster)
        @cluster = !([false, "false"].include?(is_cluster_opt))
        @element_lookup = element_lookup
        @exclusion_registry = excl_registry
        @element_id = SecureRandom.uuid
        @elements = []
        @node_options = opts
      end

      def cluster?
        @cluster
      end

      def element_ids
        @elements.flat_map(&:element_ids).uniq
      end

      def node(element_or_id, **kwargs)
        element = element_or_id.respond_to?(:element_id) ? element_or_id : @element_lookup.lookup(element_or_id)
        @elements << DiagramNode.new(element, **kwargs)
      end

      def comment(comment_text, **kwargs)
        c = Comment.new(comment_text, **kwargs)
        @elements << c
        c
      end

      def group(element_or_id, **kwargs, &blk)
        element = element_or_id.respond_to?(:element_id) ? element_or_id : @element_lookup.lookup(element_or_id)
        dg_ele = DiagramGroup.new(@element_lookup, @exclusion_registry, element, **kwargs)
        @elements << dg_ele
        dg_ele.instance_exec(&blk) if blk
        dg_ele.element_ids.each do |e_id|
          if dg_ele.element_id != e_id
            @exclusion_registry << [element, @element_lookup.lookup(e_id), :_]
          end
        end
      end

      def layout_container(**kwargs, &blk)
        dg_ele = LayoutContainer.new(@element_lookup, @exclusion_registry, **kwargs)
        @elements << dg_ele
        dg_ele.instance_exec(&blk) if blk
        dg_ele
      end
    end
  end
end