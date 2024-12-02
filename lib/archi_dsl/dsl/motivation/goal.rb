module ArchiDsl
  module Dsl
    module Motivation
      class Goal < ModelElement
        def base_folder
          Organizations::MOTIVATION_BASE
        end

        def xsi_type
          "Goal"
        end
      end
    end
  end
end