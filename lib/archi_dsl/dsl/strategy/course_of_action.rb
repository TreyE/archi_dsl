module ArchiDsl
  module Dsl
    module Strategy
      class CourseOfAction < ModelElement
        def base_folder
          Organizations::STRATEGY_BASE
        end

        def xsi_type
          "CourseOfAction"
        end
      end
    end
  end
end