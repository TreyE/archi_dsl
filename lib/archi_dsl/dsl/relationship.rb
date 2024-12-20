module ArchiDsl
  module Dsl
    class Relationship
      attr_reader :from, :to, :element_id, :folder_name, :label

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
        @label = kwargs[:label] if kwargs.key?(:label)
        @access_type = kwargs[:accessType] if kwargs.key?(:accessType)
      end

      def evaluate_kind
        "#{@kind.to_s.capitalize}"
      end

      def to_xml(parent)
        base_attributes = {
          "identifier" => @element_id,
          "source" => @from.element_id,
          "target" => @to.element_id,
          "xsi:type" => evaluate_kind
        }
        base_attributes["accessType"] = @access_type if @access_type
        if @label
          parent["archimate"].relationship(base_attributes) do |a_node|
            a_node[:archimate].name(@label)
          end
        else
          parent["archimate"].relationship(base_attributes)
        end
      end

      def matches_both_element_ids?(element_ids)
        element_ids.include?(@to.element_id) && element_ids.include?(@from.element_id)
      end

      def excluded_by?(exclusion_list)
        exclusion_list.any? do |exclusion|
          f, t, assoc = exclusion
          (f.element_id == from.element_id || f == :_) &&
            (t.element_id == to.element_id || t == :_)  &&
            (assoc == @kind || assoc == :_)
        end
      end
    end
  end
end