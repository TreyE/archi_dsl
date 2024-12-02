module ArchiDsl
  module Dsl
    module Motivation
      class Constraint < ModelElement
        def base_folder
          Organizations::MOTIVATION_BASE
        end

        def xsi_type
          "Constraint"
        end
      end
    end
  end
end