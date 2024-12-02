module ArchiDsl
  module Dsl
    class Relationship
      attr_reader :from, :to, :element_id, :folder_name

      def initialize(from, to, kind, **kwargs)
        @element_id = kwargs.fetch(:id, "e-" + SecureRandom.uuid)
        @to = to
        @from = from
        @kind = kind
        if kwargs.key?(:folder)
          @folder_name = Organizations::RELATIONS_BASE + "/" + kwargs[:folder]
        else
          @folder_name = Organizations::RELATIONS_BASE
        end
      end

      def evaluate_kind
        "#{@kind.to_s.capitalize}"
      end

      def to_xml(parent)
        parent["archimate"].relationship("identifier" => @element_id, "source" => @from.element_id, "target" => @to.element_id, "xsi:type" => evaluate_kind)
      end

      def matches_both_element_ids?(element_ids)
        element_ids.include?(@to.element_id) && element_ids.include?(@from.element_id)
      end

      def excluded_by?(exclusion_list)
        exclusion_list.any? do |exclusion|
          f, t, assoc = exclusion
          f.element_id == from.element_id &&
            t.element_id == to.element_id &&
            assoc == @kind
        end
      end
    end
  end
end