module ArchiDsl
  module Dsl
    module Motivation
      class Requirement < ModelElement
        def base_folder
          Organizations::MOTIVATION_BASE
        end

        def xsi_type
          "Requirement"
        end
      end
    end
  end
end