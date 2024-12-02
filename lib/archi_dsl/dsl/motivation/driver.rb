module ArchiDsl
  module Dsl
    module Motivation
      class Driver < ModelElement
        def base_folder
          Organizations::MOTIVATION_BASE
        end

        def xsi_type
          "Driver"
        end
      end
    end
  end
end