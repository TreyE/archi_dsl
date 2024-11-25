module ArchiDsl
  module Dsl
    module AssociationMethods
      ASSOCIATION_ELEMENTS = [
        :composition,
        :aggregation,
        :assignment,
        :realization,
        :serving,
        :access,
        :influence,
        :triggering,
        :flow,
        :specialization,
        :association
      ]

      def self.define_assoc_method(name)
        class_eval(<<-RUBY_CODE)
          def #{name}(from, to)
            @association_registry.add_association(from, to, :#{name})
          end
        RUBY_CODE
      end

      ASSOCIATION_ELEMENTS.each do |a_method|
        define_assoc_method(a_method)
      end
    end
  end
end