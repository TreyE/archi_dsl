module ArchiDsl
  module Dsl
    module Motivation
      class Assessment < ModelElement
        def base_folder
          Organizations::MOTIVATION_BASE
        end

        def xsi_type
          "Assessment"
        end
      end
    end
  end
end