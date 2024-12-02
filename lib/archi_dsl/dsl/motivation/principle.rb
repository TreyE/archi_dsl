module ArchiDsl
  module Dsl
    module Motivation
      class Principle < ModelElement
        def base_folder
          Organizations::MOTIVATION_BASE
        end

        def xsi_type
          "Principle"
        end
      end
    end
  end
end