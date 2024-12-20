module ArchiDsl
  module View
    class Comment
      attr_reader :element_id, :name

      def initialize(comment_text, **kwargs)
        @comment_text = comment_text
        @element_id = "v-comment-" + SecureRandom.uuid
        @opts = kwargs
      end

      def name
        @comment_text
      end

      def element_ids
        [@element_id]
      end

      def fixed_size?
        false
      end

      def apply_options(node)
        @opts.each_pair do |k, v|
          node[k] = v
        end
      end
    end
  end
end