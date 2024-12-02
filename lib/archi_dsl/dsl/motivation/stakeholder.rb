module ArchiDsl
  module Dsl
    module Motivation
      class Stakeholder < ModelElement
        def base_folder
          Organizations::MOTIVATION_BASE
        end

        def xsi_type
          "Stakeholder"
        end
      end
    end
  end
end