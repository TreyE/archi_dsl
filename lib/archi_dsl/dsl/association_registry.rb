module ArchiDsl
  module Dsl
    class AssociationRegistry
      attr_reader :associations

      def initialize(e_lookup)
        @associations = []
        @element_lookup = e_lookup
      end

      def add_association(from, to, kind, **kwargs)
        from_element = from.respond_to?(:element_id) ? from : @element_lookup.lookup(from)
        to_element = to.respond_to?(:element_id) ? to : @element_lookup.lookup(to)
        raise from.inspect if from_element.nil?
        @associations << Relationship.new(from_element, to_element, kind, **kwargs)
      end

      def filter_to(element_ids, exclusion_registry)
        @associations.select do |assoc|
          assoc.matches_both_element_ids?(element_ids) &&
            !assoc.excluded_by?(exclusion_registry)
        end
      end
    end
  end
end