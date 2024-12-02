module ArchiDsl
  module Dsl
    module Motivation
      class Outcome < ModelElement
        def base_folder
          Organizations::MOTIVATION_BASE
        end

        def xsi_type
          "Outcome"
        end
      end
    end
  end
end